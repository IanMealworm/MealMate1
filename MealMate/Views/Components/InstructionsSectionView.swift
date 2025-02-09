import SwiftUI

struct InstructionsSectionView: View {
    @Binding var instructions: [String]
    @Binding var stepIngredients: [Int: [Ingredient]]
    let ingredients: [Ingredient]
    let accentColor: Color
    @State private var newInstruction = ""
    @State private var showingIngredientPicker = false
    @State private var selectedStep: Int?
    
    var body: some View {
        VStack {
            ForEach(instructions.indices, id: \.self) { index in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("\(index + 1).")
                            .foregroundStyle(.secondary)
                        Text(instructions[index])
                        Spacer()
                        Button {
                            selectedStep = index
                            showingIngredientPicker = true
                        } label: {
                            Image(systemName: "link")
                                .foregroundStyle(accentColor)
                        }
                    }
                    
                    if let stepIngs = stepIngredients[index], !stepIngs.isEmpty {
                        Text("Using: " + stepIngs.map { $0.name }.joined(separator: ", "))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .onDelete { instructions.remove(atOffsets: $0) }
            .onMove { instructions.move(fromOffsets: $0, toOffset: $1) }
            
            HStack {
                TextField("Add step", text: $newInstruction)
                
                Button {
                    guard !newInstruction.isEmpty else { return }
                    instructions.append(newInstruction)
                    newInstruction = ""
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(accentColor)
                }
                .disabled(newInstruction.isEmpty)
            }
        }
        .sheet(isPresented: $showingIngredientPicker) {
            if let step = selectedStep {
                NavigationStack {
                    List(ingredients) { ingredient in
                        let isSelected = stepIngredients[step]?.contains(ingredient) ?? false
                        Button {
                            toggleIngredient(ingredient, forStep: step)
                        } label: {
                            HStack {
                                Text(ingredient.name)
                                Spacer()
                                if isSelected {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(accentColor)
                                }
                            }
                        }
                    }
                    .navigationTitle("Select Ingredients")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                showingIngredientPicker = false
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func toggleIngredient(_ ingredient: Ingredient, forStep step: Int) {
        var currentIngredients = stepIngredients[step] ?? []
        if let index = currentIngredients.firstIndex(of: ingredient) {
            currentIngredients.remove(at: index)
        } else {
            currentIngredients.append(ingredient)
        }
        stepIngredients[step] = currentIngredients
    }
} 