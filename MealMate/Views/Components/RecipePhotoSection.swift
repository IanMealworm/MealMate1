import SwiftUI
import PhotosUI

struct RecipePhotoSection: View {
    let recipe: Recipe
    let recipeStore: RecipeStore
    
    var body: some View {
        if let imageData = recipe.imageData,
           let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: 300)
                .clipped()
                .overlay(alignment: .bottomTrailing) {
                    Button {
                        recipeStore.toggleFavorite(recipe)
                    } label: {
                        Image(systemName: recipe.isFavorite ? "heart.fill" : "heart")
                            .font(.title2)
                            .foregroundStyle(recipe.isFavorite ? .red : .white)
                            .padding(12)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    .padding()
                }
        }
    }
} 