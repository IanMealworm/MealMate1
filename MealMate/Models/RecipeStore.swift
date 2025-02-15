import Foundation
import SwiftUI
import os

@MainActor
class RecipeStore: ObservableObject {
    @Published private(set) var recipes: [Recipe] = []
    let ingredientStore: IngredientStore
    let kitchenwareStore: KitchenwareStore
    
    private let fileManager = FileManager.default
    private var documentsURL: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    var iCloudURL: URL? {
        fileManager.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents")
    }
    
    private let logger = Logger(subsystem: "com.yourcompany.MealMate", category: "RecipeStore")
    
    init(
        ingredientStore: IngredientStore? = nil,
        kitchenwareStore: KitchenwareStore? = nil
    ) {
        self.ingredientStore = ingredientStore ?? IngredientStore()
        self.kitchenwareStore = kitchenwareStore ?? KitchenwareStore()
        
        // Setup iCloud document storage
        setupiCloudDocuments()
        
        // Load recipes
        Task {
            await loadRecipes()
        }
    }
    
    private func setupiCloudDocuments() {
        logger.info("Setting up iCloud Documents...")
        
        if let iCloudDocsURL = iCloudURL {
            logger.info("iCloud URL available: \(iCloudDocsURL.path)")
            do {
                try fileManager.createDirectory(at: iCloudDocsURL, withIntermediateDirectories: true)
                logger.info("Successfully created iCloud directory")
            } catch {
                logger.error("Error creating iCloud directory: \(error.localizedDescription)")
            }
        } else {
            logger.warning("iCloud URL not available. Check iCloud settings and entitlements.")
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleiCloudChanges),
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: nil
        )
        logger.info("Added iCloud change observer")
    }
    
    private func loadRecipes() async {
        logger.info("Starting recipe load...")
        
        if let iCloudDocsURL = iCloudURL {
            do {
                let files = try fileManager.contentsOfDirectory(
                    at: iCloudDocsURL,
                    includingPropertiesForKeys: nil
                ).filter { $0.pathExtension == "mealmate" }
                
                logger.info("Found \(files.count) recipes in iCloud")
                
                var loadedRecipes: [Recipe] = []
                for fileURL in files {
                    do {
                        if let recipe = try? loadRecipe(from: fileURL) {
                            loadedRecipes.append(recipe)
                            logger.info("Loaded recipe: \(recipe.name)")
                        }
                    } catch {
                        logger.error("Error loading recipe from \(fileURL.lastPathComponent): \(error.localizedDescription)")
                    }
                }
                
                await MainActor.run {
                    self.recipes = loadedRecipes
                    logger.info("Updated recipes array with \(loadedRecipes.count) recipes")
                }
                return
            } catch {
                logger.error("Error accessing iCloud directory: \(error.localizedDescription)")
            }
        } else {
            logger.warning("iCloud not available, falling back to local storage")
        }
        
        // Fallback to local storage
        if let loadedRecipes = FileStorage.load([Recipe].self, from: "SavedRecipes.json") {
            await MainActor.run {
                self.recipes = loadedRecipes
                logger.info("Loaded \(loadedRecipes.count) recipes from local storage")
            }
        } else {
            logger.warning("No recipes found in local storage")
        }
    }
    
    private func loadRecipe(from url: URL) throws -> Recipe {
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(Recipe.self, from: data)
    }
    
    private func saveRecipe(_ recipe: Recipe) throws {
        logger.info("Saving recipe: \(recipe.name)")
        
        // Save ingredients and kitchenware first
        for ingredient in recipe.ingredients {
            ingredientStore.addIngredient(ingredient.name, defaultUnit: ingredient.unit)
            logger.info("Saved ingredient: \(ingredient.name)")
        }
        
        for item in recipe.kitchenware {
            kitchenwareStore.addKitchenware(item)
            logger.info("Saved kitchenware: \(item)")
        }
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(recipe)
        
        if let iCloudDocsURL = iCloudURL {
            let fileURL = iCloudDocsURL.appendingPathComponent("\(recipe.id.uuidString).mealmate")
            try data.write(to: fileURL)
            logger.info("Saved recipe to iCloud: \(fileURL.lastPathComponent)")
        } else {
            logger.warning("iCloud not available, saving only locally")
        }
        
        FileStorage.save(recipes, to: "SavedRecipes.json")
        logger.info("Saved recipe to local storage")
    }
    
    func addRecipe(_ recipe: Recipe) {
        recipes.append(recipe)
        
        do {
            try saveRecipe(recipe)
                } catch {
            print("Error saving recipe: \(error)")
        }
    }
    
    func updateRecipe(_ recipe: Recipe) {
        if let index = recipes.firstIndex(where: { $0.id == recipe.id }) {
            recipes[index] = recipe
            
                    do {
                try saveRecipe(recipe)
                    } catch {
                print("Error updating recipe: \(error)")
            }
        }
    }
    
    func deleteRecipe(_ recipe: Recipe) {
        recipes.removeAll { $0.id == recipe.id }
        
        // Delete from iCloud if available
        if let iCloudDocsURL = iCloudURL {
            let fileURL = iCloudDocsURL.appendingPathComponent("\(recipe.id.uuidString).mealmate")
            try? fileManager.removeItem(at: fileURL)
        }
        
        // Update local backup
        FileStorage.save(recipes, to: "SavedRecipes.json")
    }
    
    func toggleFavorite(_ recipe: Recipe) {
        var updatedRecipe = recipe
        updatedRecipe.isFavorite.toggle()
        updateRecipe(updatedRecipe)
    }
    
    @objc private func handleiCloudChanges(_ notification: Notification) {
        logger.info("Received iCloud change notification")
        if let userInfo = notification.userInfo {
            logger.info("Change details: \(userInfo)")
        }
        Task {
            await loadRecipes()
        }
    }
} 