import Foundation
import SwiftUI

@MainActor
class RecipeStore: ObservableObject {
    @Published private(set) var recipes: [Recipe] = []
    let ingredientStore: IngredientStore
    let kitchenwareStore: KitchenwareStore
    private let filename = "SavedRecipes.json"
    private let oldSaveKey = "SavedRecipes"
    
    nonisolated init(
        ingredientStore: IngredientStore? = nil,
        kitchenwareStore: KitchenwareStore? = nil
    ) {
        self.ingredientStore = ingredientStore ?? IngredientStore()
        self.kitchenwareStore = kitchenwareStore ?? KitchenwareStore()
        
        Task { @MainActor in
            // First try to load from file
            if let loadedRecipes = FileStorage.load([Recipe].self, from: self.filename) {
                self.recipes = loadedRecipes
            } else {
                // If file doesn't exist, try to migrate from UserDefaults
                self.migrateFromUserDefaults()
            }
        }
    }
    
    private func migrateFromUserDefaults() {
        guard let data = UserDefaults.standard.data(forKey: oldSaveKey) else { return }
        
        do {
            // Try to decode with current format
            recipes = try JSONDecoder().decode([Recipe].self, from: data)
            // Save to file system
            FileStorage.save(recipes, to: filename)
            // Clean up UserDefaults
            UserDefaults.standard.removeObject(forKey: oldSaveKey)
        } catch {
            print("Error migrating from UserDefaults: \(error)")
            // If migration fails, start with empty recipes
            recipes = []
        }
    }
    
    func addRecipe(_ recipe: Recipe) {
        recipes.append(recipe)
        save()
    }
    
    func deleteRecipe(_ recipe: Recipe) {
        recipes.removeAll { $0.id == recipe.id }
        save()
    }
    
    func toggleFavorite(_ recipe: Recipe) {
        if let index = recipes.firstIndex(where: { $0.id == recipe.id }) {
            recipes[index].isFavorite.toggle()
            save()
        }
    }
    
    func updateRecipe(_ recipe: Recipe) {
        if let index = recipes.firstIndex(where: { $0.id == recipe.id }) {
            recipes[index] = recipe
            save()
        }
    }
    
    private func save() {
        FileStorage.save(recipes, to: filename)
    }
    
    private func loadRecipes() {
        guard let data = UserDefaults.standard.data(forKey: "SavedRecipes") else { return }
        
        do {
            // First, try to decode with the new format
            recipes = try JSONDecoder().decode([Recipe].self, from: data)
        } catch {
            print("Error loading recipes with new format: \(error)")
            
            // If that fails, try to decode the old format and migrate
            do {
                // Define a struct that matches the old data format
                struct OldRecipe: Codable {
                    let id: UUID
                    var name: String
                    var description: String
                    var ingredients: [String]  // Old format had [String]
                    var instructions: [String]
                    var cookTime: Int
                    var servings: Int
                    var isFavorite: Bool
                    var kitchenware: [String]
                    var imageData: Data?
                }
                
                let oldRecipes = try JSONDecoder().decode([OldRecipe].self, from: data)
                
                // Convert old recipes to new format
                recipes = oldRecipes.map { oldRecipe in
                    Recipe(
                        id: oldRecipe.id,
                        name: oldRecipe.name,
                        description: oldRecipe.description,
                        ingredients: oldRecipe.ingredients.map { Ingredient(name: $0, amount: 1, unit: .piece) },
                        instructions: oldRecipe.instructions,
                        cookTime: oldRecipe.cookTime,
                        servings: oldRecipe.servings,
                        isFavorite: oldRecipe.isFavorite,
                        kitchenware: oldRecipe.kitchenware,
                        imageData: oldRecipe.imageData
                    )
                }
                
                // Save in new format
                save()
                
            } catch {
                print("Error migrating old recipes: \(error)")
                // If all else fails, start with empty recipes
                recipes = []
            }
        }
    }
} 