import SwiftUI

struct RecipeSelectionView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var recipeStore: RecipeStore
    @ObservedObject var recipeBookStore: RecipeBookStore
    let book: RecipeBook
    
    @State private var searchText = ""
    @State private var selectedCategory: Recipe.Category?
    
    private var filteredRecipes: [Recipe] {
        var recipes = recipeStore.recipes
            .filter { !book.recipeIds.contains($0.id) } // Only show recipes not already in book
        
        if let category = selectedCategory {
            recipes = recipes.filter { $0.category == category }
        }
        
        if !searchText.isEmpty {
            recipes = recipes.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        return recipes
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Search Bar
                    SearchBar(text: $searchText, placeholder: "Search recipes...")
                        .padding(.horizontal)
                    
                    // Categories
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
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
                    
                    // Recipes List
                    VStack(alignment: .leading, spacing: 16) {
                        if filteredRecipes.isEmpty {
                            ContentUnavailableView(
                                "No Recipes Available",
                                systemImage: "book",
                                description: Text("All recipes are already in this book or no recipes match your search")
                            )
                        } else {
                            VStack(spacing: 12) {
                                ForEach(filteredRecipes) { recipe in
                                    Button {
                                        recipeBookStore.addRecipeToBook(recipe.id, bookId: book.id)
                                    } label: {
                                        HStack {
                                            RecipeRowView(recipe: recipe)
                                            
                                            Image(systemName: "plus.circle.fill")
                                                .foregroundStyle(book.color.color)
                                                .font(.title2)
                                        }
                                        .padding()
                                        .background(Color(.secondarySystemBackground))
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Add Recipes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
} 