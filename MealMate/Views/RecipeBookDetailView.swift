import SwiftUI

struct RecipeBookDetailView: View {
    let book: RecipeBook
    @ObservedObject var recipeBookStore: RecipeBookStore
    @ObservedObject var recipeStore: RecipeStore
    @ObservedObject var ingredientStore: IngredientStore
    @ObservedObject var kitchenwareStore: KitchenwareStore
    @ObservedObject var shoppingListStore: ShoppingListStore
    @State private var showingAddRecipes = false
    @State private var showingShareSheet = false
    @State private var showingSaveOptions = false
    @State private var exportURL: URL?
    
    private var bookRecipes: [Recipe] {
        if let exportedRecipes = book.exportedRecipes {
            // This is an imported book with full recipes
            return exportedRecipes
        } else {
            // This is a local book with recipe IDs
            return recipeStore.recipes.filter { book.recipeIds.contains($0.id) }
        }
    }
    
    // Add this computed property to check for unsaved recipes
    private var hasUnsavedRecipes: Bool {
        guard let exportedRecipes = book.exportedRecipes else { return false }
        return exportedRecipes.contains { recipe in
            !recipeStore.recipes.contains { $0.id == recipe.id }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Cover Image
                if let imageData = book.imageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    Image(systemName: "book.closed.fill")
                        .font(.system(size: 60))
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                        .background(book.color.color.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // Description
                if !book.description.isEmpty {
                    Text(book.description)
                        .foregroundStyle(.secondary)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // Recipes Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "book")
                            .foregroundStyle(book.color.color)
                        Text("RECIPES")
                            .foregroundStyle(book.color.color)
                        
                        Spacer()
                        
                        Button {
                            showingAddRecipes = true
                        } label: {
                            Label("Add Recipes", systemImage: "plus")
                                .font(.subheadline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(book.color.color)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                    }
                    .font(.headline)
                    
                    if bookRecipes.isEmpty {
                        Text("No recipes added yet")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        VStack(spacing: 12) {
                            ForEach(bookRecipes) { recipe in
                                NavigationLink(destination: RecipeDetailView(
                                    recipe: recipe,
                                    recipeStore: recipeStore,
                                    shoppingListStore: shoppingListStore
                                )) {
                                    RecipeRowView(recipe: recipe)
                                }
                                .contextMenu {
                                    if book.exportedRecipes != nil {
                                        Button {
                                            saveRecipe(recipe)
                                        } label: {
                                            Label("Save to My Recipes", systemImage: "square.and.arrow.down")
                                        }
                                    }
                                    
                                    Button(role: .destructive) {
                                        recipeBookStore.removeRecipeFromBook(recipe.id, bookId: book.id)
                                    } label: {
                                        Label("Remove", systemImage: "minus.circle")
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding()
            
            // Update the save button visibility check
            if hasUnsavedRecipes {  // Changed from book.exportedRecipes != nil
                Button {
                    showingSaveOptions = true
                } label: {
                    Label("Save Recipes", systemImage: "square.and.arrow.down")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(book.color.color)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding()
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(book.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    exportBook()
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .sheet(isPresented: $showingAddRecipes) {
            RecipeSelectionView(
                recipeStore: recipeStore,
                recipeBookStore: recipeBookStore,
                book: book
            )
        }
        .sheet(isPresented: $showingShareSheet, onDismiss: {
            // Clean up temporary file when sheet is dismissed
            if let url = exportURL {
                try? FileManager.default.removeItem(at: url)
            }
        }) {
            if let url = exportURL {
                ShareSheet(items: [url])
                    .presentationDetents([.medium])
            }
        }
        .confirmationDialog(
            "Save Recipes",
            isPresented: $showingSaveOptions,
            titleVisibility: .visible
        ) {
            Button("Save All Recipes") {
                saveAllRecipes()
            }
            
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Would you like to save all recipes to your collection?")
        }
    }
    
    private func exportBook() {
        // Create a new book with full recipes
        var exportBook = book
        exportBook.exportedRecipes = bookRecipes // Include full recipes for export
        
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(exportBook)
            
            // Create a unique filename with timestamp
            let timestamp = Int(Date().timeIntervalSince1970)
            let filename = "\(book.name.replacingOccurrences(of: " ", with: "_"))_\(timestamp).mealmatebook"
            
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
            
            // Remove existing file if it exists
            if FileManager.default.fileExists(atPath: tempURL.path) {
                try FileManager.default.removeItem(at: tempURL)
            }
            
            try data.write(to: tempURL)
            self.exportURL = tempURL
            self.showingShareSheet = true
            
        } catch {
            print("Error exporting book: \(error.localizedDescription)")
        }
    }
    
    private func saveAllRecipes() {
        guard let recipes = book.exportedRecipes else { return }
        
        for recipe in recipes {
            // Save ingredients to ingredient store
            for ingredient in recipe.ingredients {
                ingredientStore.addIngredient(
                    ingredient.name,
                    defaultUnit: ingredient.unit
                )
            }
            
            // Save kitchenware to kitchenware store
            for item in recipe.kitchenware {
                kitchenwareStore.addKitchenware(item)
            }
            
            // Save recipe
            recipeStore.addRecipe(recipe)
        }
    }
    
    private func saveRecipe(_ recipe: Recipe) {
        // Save ingredients to ingredient store
        for ingredient in recipe.ingredients {
            ingredientStore.addIngredient(
                ingredient.name,
                defaultUnit: ingredient.unit
            )
        }
        
        // Save kitchenware to kitchenware store
        for item in recipe.kitchenware {
            kitchenwareStore.addKitchenware(item)
        }
        
        // Save recipe
        recipeStore.addRecipe(recipe)
    }
} 