import SwiftUI

struct InstructionsSection: View {
    let recipe: Recipe
    let recipeStore: RecipeStore
    
    var body: some View {
        Section(
            header: SectionHeader(
                title: "Instructions",
                icon: "list.number",
                color: recipe.category.color,
                trailingContent: {
                    AnyView(
                        NavigationLink {
                            StepByStepView(recipe: recipe, recipeStore: recipeStore)
                        } label: {
                            Label("Step by Step", systemImage: "play.fill")
                                .font(.subheadline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(recipe.category.color)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                    )
                }
            )
        ) {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(Array(recipe.instructions.enumerated()), id: \.element) { index, instruction in
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Step \(index + 1):")
                            .font(.headline)
                            .foregroundStyle(recipe.category.color)
                        
                        Text(instruction)
                            .font(.subheadline)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(recipe.category.color.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
    }
} 