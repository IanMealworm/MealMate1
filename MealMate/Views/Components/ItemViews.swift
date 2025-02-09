import SwiftUI

struct KitchenwareItemView: View {
    let name: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: "circle.fill")
                .font(.system(size: 8))
                .foregroundStyle(color)
            Text(name)
                .font(.subheadline)
            Spacer()
        }
        .padding(12)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct IngredientItemView: View {
    let ingredient: Ingredient
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(ingredient.name)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Text("\(String(format: "%.1f", ingredient.amount)) \(ingredient.unit.rawValue)")
                .font(.caption)
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
} 