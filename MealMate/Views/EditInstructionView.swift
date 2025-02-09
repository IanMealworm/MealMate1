import SwiftUI

struct EditInstructionView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var instructions: [String]
    @Binding var stepIngredients: [Int: [Ingredient]]
    let stepIndex: Int
    let ingredients: [Ingredient]
    let accentColor: Color
    
    @State private var editedInstruction: String
    @State private var selectedIngredients: [Ingredient]
    
    init(instructions: Binding<[String]>, 
         stepIngredients: Binding<[Int: [Ingredient]]>, 
         stepIndex: Int,
         ingredients: [Ingredient],
         accentColor: Color) {
        self._instructions = instructions
        self._stepIngredients = stepIngredients
        self.stepIndex = stepIndex
        self.ingredients = ingredients
        self.accentColor = accentColor
        
        // Initialize state
        _editedInstruction = State(initialValue: instructions.wrappedValue[stepIndex])
        _selectedIngredients = State(initialValue: stepIngredients.wrappedValue[stepIndex] ?? [])
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Instruction Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "text.justify")
                                .foregroundStyle(.purple)
                            Text("INSTRUCTION")
                                .foregroundStyle(.purple)
                        }
                        .font(.headline)
                        
                        TextField("Instruction", text: $editedInstruction, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .padding()
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    // Ingredients Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "carrot.fill")
                                .foregroundStyle(.purple)
                            Text("STEP INGREDIENTS")
                                .foregroundStyle(.purple)
                        }
                        .font(.headline)
                        
                        VStack(spacing: 12) {
                            ForEach(ingredients) { ingredient in
                                Button {
                                    if let index = selectedIngredients.firstIndex(where: { $0.id == ingredient.id }) {
                                        selectedIngredients.remove(at: index)
                                    } else {
                                        selectedIngredients.append(ingredient)
                                    }
                                } label: {
                                    HStack {
                                        Text(ingredient.name)
                                        Spacer()
                                        if selectedIngredients.contains(where: { $0.id == ingredient.id }) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(.purple)
                                        } else {
                                            Image(systemName: "circle")
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    .padding()
                                    .background(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding()
            }
            .background(Color(.systemGray6))
            .navigationTitle("Edit Step \(stepIndex + 1)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        withAnimation {
                            instructions[stepIndex] = editedInstruction
                            stepIngredients[stepIndex] = selectedIngredients
                        }
                        dismiss()
                    }
                    .disabled(editedInstruction.isEmpty)
                }
            }
        }
    }
}

#Preview {
    EditInstructionView(
        instructions: .constant(["Step 1", "Step 2", "Step 3"]),
        stepIngredients: .constant([:]),
        stepIndex: 0,
        ingredients: [
            Ingredient(name: "Chicken"),
            Ingredient(name: "Tomatoes")
        ],
        accentColor: .purple
    )
} 