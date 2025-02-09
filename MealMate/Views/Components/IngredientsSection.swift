import SwiftUI

struct IngredientsSection: View {
    let recipe: Recipe
    let shoppingListStore: ShoppingListStore
    
    private let gridColumns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        Section(header: SectionHeader(title: "Ingredients", icon: "basket", color: recipe.category.color)) {
            LazyVGrid(columns: gridColumns, spacing: 12) {
                ForEach(recipe.ingredients) { ingredient in
                    IngredientItemView(ingredient: ingredient, color: recipe.category.color)
                }
            }
        }
    }
} 