import SwiftUI

struct RecipeRowView: View {
    let recipe: Recipe
    
    var body: some View {
        HStack(spacing: 16) {
            // Recipe Image with Favorite Overlay
            ZStack(alignment: .topTrailing) {
                if let imageData = recipe.imageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(recipe.category.color.opacity(0.1))
                        .frame(width: 80, height: 80)
                        .overlay {
                            Image(systemName: recipe.category.icon)
                                .font(.title2)
                                .foregroundStyle(recipe.category.color)
                        }
                }
                
                // Favorite Icon Overlay
                if recipe.isFavorite {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(.red)
                        .font(.caption)
                        .padding(6)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                        .padding(4)
                }
            }
            
            // Recipe Info
            VStack(alignment: .leading, spacing: 8) {
                Text(recipe.name)
                    .font(.headline)
                    .lineLimit(1)
                
                // Category Badge
                Text(recipe.category.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(recipe.category.color.opacity(0.1))
                    .foregroundStyle(recipe.category.color)
                    .clipShape(Capsule())
                
                // Time and Servings
                HStack(spacing: 12) {
                    Label("\(recipe.cookTime)m", systemImage: "clock")
                    Label("\(recipe.servings) serv", systemImage: "person.2")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Navigation Arrow
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.trailing, 4)
        }
    }
} 