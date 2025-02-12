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
    @State private var searchText = ""
    @StateObject private var ingredientStore = IngredientStore()
    @StateObject private var kitchenwareStore = KitchenwareStore()
    
    // Break down the filtering into smaller functions
    private func filterByCategory(_ recipes: [Recipe]) -> [Recipe] {
        guard let category = selectedCategory else { return recipes }
        return recipes.filter { $0.category == category }
    }
    
    private func filterByFavorites(_ recipes: [Recipe]) -> [Recipe] {
        guard showFavoritesOnly else { return recipes }
        return recipes.filter { $0.isFavorite }
    }
    
    private func filterBySearch(_ recipes: [Recipe], searchText: String) -> [Recipe] {
        guard !searchText.isEmpty else { return recipes }
        return recipes.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.description.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    private func filteredRecipes(searchText: String) -> [Recipe] {
        var result = recipeStore.recipes
        result = filterByCategory(result)
        result = filterByFavorites(result)
        result = filterBySearch(result, searchText: searchText)
        return result
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
            RecipeListView(
                recipes: filteredRecipes(searchText: searchText),
                recipeStore: recipeStore,
                shoppingListStore: shoppingListStore,
                selectedCategory: $selectedCategory,
                showFavoritesOnly: $showFavoritesOnly,
                searchText: $searchText
            )
            .navigationTitle("Recipes")
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
                                if !ingredientStore.ingredients.contains(ingredient.name) {
                                    ingredientStore.addIngredient(
                                        ingredient.name,
                                        defaultUnit: ingredient.unit
                                    )
                                }
                            }
                            
                            // Import kitchenware
                            for item in recipe.kitchenware {
                                if !kitchenwareStore.kitchenware.contains(item) {
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

// Move RecipeListView to a separate component
struct RecipeListView: View {
    let recipes: [Recipe]
    let recipeStore: RecipeStore
    let shoppingListStore: ShoppingListStore
    @Binding var selectedCategory: Recipe.Category?
    @Binding var showFavoritesOnly: Bool
    @Binding var searchText: String
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Add SearchBar at the top
                SearchBar(text: $searchText, placeholder: "Search recipes...")
                    .padding(.horizontal)
                
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
                    
                    if recipes.isEmpty {
                        ContentUnavailableView(
                            "No Recipes",
                            systemImage: "book",
                            description: Text("Add your first recipe to get started")
                        )
                        .padding()
                    } else {
                        VStack(spacing: 12) {
                            ForEach(recipes) { recipe in
                                makeRecipeRow(recipe)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
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
} 