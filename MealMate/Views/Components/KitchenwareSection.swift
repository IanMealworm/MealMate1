import SwiftUI

struct KitchenwareSection: View {
    let recipe: Recipe
    
    private let gridColumns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        Section(header: SectionHeader(title: "Kitchenware Needed", icon: "fork.knife", color: recipe.category.color)) {
            LazyVGrid(columns: gridColumns, spacing: 12) {
                ForEach(recipe.kitchenware, id: \.self) { item in
                    KitchenwareItemView(name: item, color: recipe.category.color)
                }
            }
        }
    }
} 