import SwiftUI

struct EditIngredientView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var ingredientStore: IngredientStore
    let originalName: String
    @Binding var selectedIngredients: [Ingredient]
    
    @State private var name: String
    @State private var selectedUnit: Ingredient.Unit
    
    init(ingredientStore: IngredientStore, originalName: String, selectedIngredients: Binding<[Ingredient]>) {
        self.ingredientStore = ingredientStore
        self.originalName = originalName
        self._selectedIngredients = selectedIngredients
        
        // Initialize state with current values
        _name = State(initialValue: originalName)
        _selectedUnit = State(initialValue: ingredientStore.units[originalName] ?? .piece)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Input Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "pencil")
                                .foregroundStyle(.purple)
                            Text("EDIT INGREDIENT")
                                .foregroundStyle(.purple)
                        }
                        .font(.headline)
                        
                        VStack(spacing: 12) {
                            TextField("Name", text: $name)
                                .textFieldStyle(.roundedBorder)
                                .autocorrectionDisabled()
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(Ingredient.Unit.allCases, id: \.self) { unit in
                                        Button {
                                            selectedUnit = unit
                                        } label: {
                                            VStack(spacing: 4) {
                                                Text(unit.displayName)
                                                    .font(.subheadline)
                                                Text(unit.rawValue)
                                                    .font(.caption)
                                            }
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(selectedUnit == unit ? .purple : .white)
                                            .foregroundStyle(selectedUnit == unit ? .white : .primary)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .padding()
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding()
            }
            .background(Color(.systemGray6))
            .navigationTitle("Edit Ingredient")
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
                            // Update store first
                            ingredientStore.updateIngredient(
                                oldName: originalName,
                                newName: name,
                                newUnit: selectedUnit
                            )
                            
                            // Then update selected ingredients
                            for index in selectedIngredients.indices {
                                if selectedIngredients[index].name == originalName {
                                    selectedIngredients[index].name = name
                                    selectedIngredients[index].unit = selectedUnit
                                }
                            }
                        }
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
} 