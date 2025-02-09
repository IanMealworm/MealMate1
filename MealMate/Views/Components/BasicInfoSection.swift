import SwiftUI

struct BasicInfoSection: View {
    let recipe: Recipe
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !recipe.description.isEmpty {
                Text(recipe.description)
                    .font(.body)
            }
            
            HStack(spacing: 24) {
                Label("\(recipe.cookTime) min", systemImage: "clock")
                Label("\(recipe.servings) servings", systemImage: "person.2")
                Label(recipe.category.rawValue, systemImage: recipe.category.icon)
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
    }
} 