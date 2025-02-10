import SwiftUI
import UniformTypeIdentifiers

struct RecipesView: View {
    @ObservedObject var recipeStore: RecipeStore
    @ObservedObject var shoppingListStore: ShoppingListStore
    @State private var showingAddRecipe = false
    @State private var selectedCategory: Recipe.Category?
    @State private var showFavoritesOnly = false
    @State private var showingRandomizer = false
    @State private var showingImporter = false
    @StateObject private var ingredientStore = IngredientStore()
    @StateObject private var kitchenwareStore = KitchenwareStore()
    
    // Break down the filtering into smaller functions
    private func filterByFavorites(_ recipes: [Recipe]) -> [Recipe] {
        guard showFavoritesOnly else { return recipes }
        return recipes.filter { $0.isFavorite }
    }
    
    private func filterByCategory(_ recipes: [Recipe]) -> [Recipe] {
        guard let category = selectedCategory else { return recipes }
        return recipes.filter { $0.category == category }
    }
    
    var filteredRecipes: [Recipe] {
        let recipes = recipeStore.recipes
        let favoritesFiltered = filterByFavorites(recipes)
        return filterByCategory(favoritesFiltered)
    }
    
    private func makeRecipeRow(_ recipe: Recipe) -> some View {
        NavigationLink(destination: RecipeDetailView(
            recipe: recipe,
            recipeStore: recipeStore,
            shoppingListStore: shoppingListStore
        )) {
            RecipeRowView(recipe: recipe)
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .contextMenu {
            NavigationLink {
                EditRecipeView(
                    recipeStore: recipeStore,
                    shoppingListStore: shoppingListStore,
                    recipe: recipe
                )
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            
            Button(role: .destructive) {
                recipeStore.deleteRecipe(recipe)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Categories Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "tag.fill")
                                .foregroundStyle(.purple)
                            Text("CATEGORIES")
                                .foregroundStyle(.purple)
                        }
                        .font(.headline)
                        .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                Button {
                                    showFavoritesOnly.toggle()
                                } label: {
                                    Label("Favorites", systemImage: showFavoritesOnly ? "heart.fill" : "heart")
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(showFavoritesOnly ? .red : Color(.secondarySystemBackground))
                                        .foregroundStyle(showFavoritesOnly ? .white : .primary)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                
                                ForEach(Recipe.Category.allCases, id: \.self) { category in
                                    Button {
                                        selectedCategory = selectedCategory == category ? nil : category
                                    } label: {
                                        Label(category.rawValue, systemImage: category.icon)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(selectedCategory == category ? category.color : Color(.secondarySystemBackground))
                                            .foregroundStyle(selectedCategory == category ? .white : .primary)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Recipes Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "book.fill")
                                .foregroundStyle(.purple)
                            Text("MY RECIPES")
                                .foregroundStyle(.purple)
                        }
                        .font(.headline)
                        .padding(.horizontal)
                        
                        if filteredRecipes.isEmpty {
                            ContentUnavailableView(
                                "No Recipes",
                                systemImage: "book",
                                description: Text("Add your first recipe to get started")
                            )
                            .padding()
                        } else {
                            VStack(spacing: 12) {
                                ForEach(filteredRecipes) { recipe in
                                    makeRecipeRow(recipe)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("My Recipes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            showingAddRecipe = true
                        } label: {
                            Label("Add New Recipe", systemImage: "plus")
                        }
                        
                        Button {
                            showingRandomizer = true
                        } label: {
                            Label("Recipe Randomizer", systemImage: "dice.fill")
                        }
                        
                        Button {
                            showingImporter = true
                        } label: {
                            Label("Import Recipes", systemImage: "square.and.arrow.down")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingAddRecipe) {
                AddRecipeView(recipeStore: recipeStore)
            }
            .sheet(isPresented: $showingRandomizer) {
                RandomRecipeView(
                    recipeStore: recipeStore,
                    shoppingListStore: shoppingListStore
                )
            }
            .fileImporter(
                isPresented: $showingImporter,
                allowedContentTypes: [UTType(filenameExtension: "mealmate")!],
                allowsMultipleSelection: true
            ) { result in
                switch result {
                case .success(let urls):
                    for url in urls {
                        guard url.startAccessingSecurityScopedResource() else {
                            print("Failed to access security scoped resource")
                            continue
                        }
                        
                        defer {
                            url.stopAccessingSecurityScopedResource()
                        }
                        
                        do {
                            let data = try Data(contentsOf: url)
                            let recipe = try JSONDecoder().decode(Recipe.self, from: data)
                            
                            // Import ingredients
                            for ingredient in recipe.ingredients {
                                if !ingredientStore.savedIngredients.contains(ingredient.name) {
                                    ingredientStore.addIngredient(
                                        ingredient.name,
                                        defaultUnit: ingredient.unit
                                    )
                                }
                            }
                            
                            // Import kitchenware
                            for item in recipe.kitchenware {
                                if !kitchenwareStore.items.contains(item) {
                                    kitchenwareStore.addKitchenware(item)
                                }
                            }
                            
                            // Add the recipe
                            recipeStore.addRecipe(recipe)
                            
                        } catch {
                            print("Error importing recipe: \(error.localizedDescription)")
                        }
                    }
                case .failure(let error):
                    print("Error selecting files: \(error.localizedDescription)")
                }
            }
        }
    }
} 