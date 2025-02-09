import SwiftUI

struct AddNewIngredientView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var ingredientStore: IngredientStore
    @State private var name = ""
    @State private var selectedUnit: Ingredient.Unit = .piece
    
    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "carrot.fill")
                    .foregroundStyle(.purple)
                Text("NEW INGREDIENT")
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
    
    private var existingItemsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "list.bullet")
                    .foregroundStyle(.purple)
                Text("EXISTING ITEMS")
                    .foregroundStyle(.purple)
            }
            .font(.headline)
            
            VStack(spacing: 12) {
                ForEach(Array(ingredientStore.savedIngredients).sorted(), id: \.self) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item)
                            Text(ingredientStore.defaultUnits[item]?.rawValue ?? "piece")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button {
                            ingredientStore.deleteIngredient(item)
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.red)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding()
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    inputSection
                    existingItemsSection
                }
                .padding()
            }
            .background(Color(.systemGray6))
            .navigationTitle("Add Ingredient")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if !name.isEmpty {
                            ingredientStore.addIngredient(name, defaultUnit: selectedUnit)
                            dismiss()
                        }
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
} 