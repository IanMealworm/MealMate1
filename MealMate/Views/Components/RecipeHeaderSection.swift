import SwiftUI

struct RecipeHeaderSection: View {
    let recipe: Recipe
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !recipe.description.isEmpty {
                Text(recipe.description)
                    .foregroundStyle(.secondary)
            }
            
            Label(recipe.category.rawValue, systemImage: recipe.category.icon)
                .font(.subheadline)
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(recipe.category.color.gradient)
                .clipShape(Capsule())
            
            HStack(spacing: 16) {
                Label("\(recipe.cookTime) mins", systemImage: "clock")
                Label("\(recipe.servings) servings", systemImage: "person.2")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
    }
} 