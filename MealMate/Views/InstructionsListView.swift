import SwiftUI

struct InstructionsListView: View {
    @Binding var instructions: [String]
    @Binding var stepPhotos: [Int: Data]
    @Binding var stepIngredients: [Int: [Ingredient]]
    let ingredients: [Ingredient]
    let accentColor: Color
    
    @State private var showingAddStep = false
    @State private var editingStep: Int?
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(instructions.indices, id: \.self) { index in
                VStack(alignment: .leading, spacing: 12) {
                    // Step Header
                    HStack {
                        Text("Step \(index + 1)")
                            .font(.title3)
                            .foregroundStyle(accentColor)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Button {
                            editingStep = index
                        } label: {
                            Image(systemName: "pencil.circle.fill")
                                .foregroundStyle(.blue)
                        }
                    }
                    
                    // Step Photo if exists
                    if let photoData = stepPhotos[index],
                       let uiImage = UIImage(data: photoData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    // Step Instructions
                    Text(instructions[index])
                        .font(.body)
                    
                    // Step Ingredients if any
                    if let stepIngs = stepIngredients[index], !stepIngs.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Ingredients for this step:")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .padding(.bottom, 4)
                            
                            ForEach(stepIngs) { ingredient in
                                HStack(spacing: 12) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(accentColor)
                                    Text("\(String(format: "%.1f", ingredient.amount)) \(ingredient.unit.rawValue) \(ingredient.name)")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .font(.subheadline)
                            }
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray5))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            Button {
                showingAddStep = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Step")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(accentColor.opacity(0.1))
                .foregroundStyle(accentColor)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .sheet(isPresented: $showingAddStep) {
            AddInstructionStepView(
                instructions: $instructions,
                stepPhotos: $stepPhotos,
                stepIngredients: $stepIngredients,
                ingredients: ingredients,
                accentColor: accentColor
            )
        }
        .sheet(item: Binding(
            get: { editingStep.map { EditingStep($0) } },
            set: { editingStep = $0?.id }
        )) { step in
            EditInstructionView(
                instructions: $instructions,
                stepIngredients: $stepIngredients,
                stepIndex: step.id,
                ingredients: ingredients,
                accentColor: accentColor
            )
        }
    }
}

struct EditingStep: Identifiable {
    let id: Int
    
    init(_ index: Int) {
        self.id = index
    }
}

#Preview {
    InstructionsListView(
        instructions: .constant(["Step 1", "Step 2", "Step 3"]),
        stepPhotos: .constant([:]),
        stepIngredients: .constant([
            0: [Ingredient(name: "Chicken"), Ingredient(name: "Tomatoes")],
            1: [Ingredient(name: "Carrots"), Ingredient(name: "Onions")]
        ]),
        ingredients: [
            Ingredient(name: "Chicken"),
            Ingredient(name: "Tomatoes"),
            Ingredient(name: "Carrots"),
            Ingredient(name: "Onions")
        ],
        accentColor: .purple
    )
} 