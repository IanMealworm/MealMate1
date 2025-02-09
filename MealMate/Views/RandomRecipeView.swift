import SwiftUI

struct RandomRecipeView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var recipeStore: RecipeStore
    @ObservedObject var shoppingListStore: ShoppingListStore
    
    @State private var numberOfRecipes = 3
    @State private var selectedCategories: Set<Recipe.Category> = Set(Recipe.Category.allCases)
    @State private var randomizedRecipes: [Recipe] = []
    @State private var hasGenerated = false
    @State private var showingToast = false
    
    private var availableRecipes: [Recipe] {
        recipeStore.recipes.filter { selectedCategories.contains($0.category) }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if !hasGenerated {
                        // Setup View
                        VStack(alignment: .leading, spacing: 24) {
                            // Number of Recipes Section
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Image(systemName: "number.circle.fill")
                                        .foregroundStyle(.purple)
                                    Text("NUMBER OF RECIPES")
                                        .foregroundStyle(.purple)
                                }
                                .font(.headline)
                                
                                VStack {
                                    Stepper("\(numberOfRecipes) recipes", value: $numberOfRecipes, in: 1...10)
                                        .padding()
                                        .background(.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                            
                            // Categories Section
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Image(systemName: "tag.fill")
                                        .foregroundStyle(.purple)
                                    Text("CATEGORIES")
                                        .foregroundStyle(.purple)
                                }
                                .font(.headline)
                                
                                VStack(spacing: 12) {
                                    ForEach(Recipe.Category.allCases, id: \.self) { category in
                                        Button {
                                            if selectedCategories.contains(category) {
                                                if selectedCategories.count > 1 {
                                                    selectedCategories.remove(category)
                                                }
                                            } else {
                                                selectedCategories.insert(category)
                                            }
                                        } label: {
                                            HStack {
                                                Label(category.rawValue, systemImage: category.icon)
                                                Spacer()
                                                Image(systemName: selectedCategories.contains(category) ? "checkmark.circle.fill" : "circle")
                                            }
                                            .foregroundStyle(selectedCategories.contains(category) ? category.color : .secondary)
                                            .padding()
                                            .background(.white)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Generate Button
                        Button {
                            generateRecipes()
                        } label: {
                            Label("Generate Recipes", systemImage: "dice.fill")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.purple)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .disabled(selectedCategories.isEmpty)
                        .padding(.horizontal)
                        
                    } else {
                        // Results View
                        if !randomizedRecipes.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Image(systemName: "star.fill")
                                        .foregroundStyle(.purple)
                                    Text("SUGGESTED RECIPES")
                                        .foregroundStyle(.purple)
                                }
                                .font(.headline)
                                .padding(.horizontal)
                                
                                VStack(spacing: 12) {
                                    ForEach(randomizedRecipes) { recipe in
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
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                            VStack(spacing: 12) {
                                Button {
                                    generateRecipes()
                                } label: {
                                    Label("Generate New Selection", systemImage: "arrow.clockwise")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(.purple)
                                        .foregroundStyle(.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                
                                Button {
                                    addToShoppingList()
                                } label: {
                                    Label("Add All to Shopping List", systemImage: "cart.badge.plus")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(.green)
                                        .foregroundStyle(.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                
                                Button {
                                    hasGenerated = false
                                } label: {
                                    Text("Change Settings")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color(.systemGray5))
                                        .foregroundStyle(.primary)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                            .padding()
                        } else {
                            ContentUnavailableView(
                                "No Recipes Available",
                                systemImage: "fork.knife.circle",
                                description: Text("There aren't enough recipes saved in the selected categories.")
                            )
                        }
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGray6))
            .navigationTitle("Recipe Randomizer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .overlay(alignment: .bottom) {
                if showingToast {
                    ToastView(
                        message: "Added ingredients to shopping list",
                        icon: "checkmark.circle.fill"
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, 32)
                }
            }
        }
    }
    
    private func generateRecipes() {
        let available = availableRecipes
        randomizedRecipes = Array(available.shuffled().prefix(numberOfRecipes))
        hasGenerated = true
    }
    
    private func addToShoppingList() {
        for recipe in randomizedRecipes {
            shoppingListStore.addRecipeIngredients(recipe.ingredients)
        }
        
        withAnimation {
            showingToast = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showingToast = false
            }
        }
    }
} 
