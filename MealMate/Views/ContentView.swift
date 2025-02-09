import SwiftUI

struct ContentView: View {
    @ObservedObject var recipeStore: RecipeStore
    @ObservedObject var shoppingListStore: ShoppingListStore
    @State private var showingAddRecipe = false
    @State private var selectedCategory: Recipe.Category?
    @State private var showFavoritesOnly = false
    @State private var showingRandomizer = false
    
    init(recipeStore: RecipeStore, shoppingListStore: ShoppingListStore) {
        self.recipeStore = recipeStore
        self.shoppingListStore = shoppingListStore
    }
    
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
    
    private func makeFavoriteButton() -> some View {
        Button {
            showFavoritesOnly.toggle()
        } label: {
            Label("Favorites", systemImage: showFavoritesOnly ? "heart.fill" : "heart")
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(showFavoritesOnly ? .red : .gray.opacity(0.1))
                .foregroundStyle(showFavoritesOnly ? .white : .primary)
                .clipShape(Capsule())
        }
    }
    
    private func makeCategoryButton(for category: Recipe.Category) -> some View {
        Button {
            selectedCategory = selectedCategory == category ? nil : category
        } label: {
            Label(category.rawValue, systemImage: category.icon)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(selectedCategory == category ? category.color : .gray.opacity(0.1))
                .foregroundStyle(selectedCategory == category ? .white : .primary)
                .clipShape(Capsule())
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
                .background(.white)
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
    
    private func makeRecipeList() -> some View {
        List {
            ForEach(filteredRecipes) { recipe in
                makeRecipeRow(recipe)
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
                                        .background(showFavoritesOnly ? .red : .white)
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
                                            .background(selectedCategory == category ? category.color : .white)
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
            .background(Color(.systemGray6))
            .navigationTitle("My Recipes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button {
                            showingRandomizer = true
                        } label: {
                            Image(systemName: "dice.fill")
                        }
                        
                        Button {
                            showingAddRecipe = true
                        } label: {
                            Image(systemName: "plus")
                        }
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
        }
    }
}

#Preview {
    ContentView(
        recipeStore: RecipeStore(),
        shoppingListStore: ShoppingListStore()
    )
}
