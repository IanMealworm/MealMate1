import SwiftUI

struct EditingIngredient: Identifiable {
    let id: String
    
    init(_ name: String) {
        self.id = name
    }
}

struct IngredientSelectionView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var ingredientStore: IngredientStore
    @Binding var selectedIngredients: [Ingredient]
    @State private var showingAddNew = false
    @State private var showingQuantityInput = false
    @State private var selectedName = ""
    @State private var tempAmount = ""
    @State private var selectedUnit: Ingredient.Unit = .piece
    @State private var showingEditIngredient = false
    @State private var editingName = ""
    @State private var editingUnit: Ingredient.Unit = .piece
    @State private var originalName = ""
    @State private var editingIngredient: EditingIngredient?
    
    private var selectedNames: Set<String> {
        Set(selectedIngredients.map { $0.name })
    }
    
    private var selectedItemsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.purple)
                Text("SELECTED INGREDIENTS")
                    .foregroundStyle(.purple)
            }
            .font(.headline)
            
            if selectedIngredients.isEmpty {
                Text("No ingredients selected")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                VStack(spacing: 12) {
                    ForEach(selectedIngredients) { ingredient in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(ingredient.name)
                                Text("\(String(format: "%.1f", ingredient.amount)) \(ingredient.unit.rawValue)")
                                    .font(.caption)
                                    .foregroundStyle(.purple)
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 12) {
                                Button {
                                    selectedName = ingredient.name
                                    tempAmount = String(format: "%.1f", ingredient.amount)
                                    selectedUnit = ingredient.unit
                                    showingQuantityInput = true
                                } label: {
                                    Image(systemName: "pencil.circle.fill")
                                        .foregroundStyle(.blue)
                                }
                                
                                Button {
                                    selectedIngredients.removeAll { $0.id == ingredient.id }
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.red)
                                }
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
    }
    
    private var availableItemsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "carrot.fill")
                    .foregroundStyle(.purple)
                Text("AVAILABLE INGREDIENTS")
                    .foregroundStyle(.purple)
            }
            .font(.headline)
            
            VStack(spacing: 12) {
                ForEach(Array(ingredientStore.savedIngredients).sorted(), id: \.self) { item in
                    HStack {
                        Button {
                            selectedName = item
                            selectedUnit = ingredientStore.defaultUnits[item] ?? .piece
                            tempAmount = "1.0"
                            showingQuantityInput = true
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(item)
                                    Text(ingredientStore.defaultUnits[item]?.rawValue ?? "piece")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: selectedNames.contains(item) ? "checkmark.circle.fill" : "plus.circle")
                                    .foregroundStyle(selectedNames.contains(item) ? .purple : .blue)
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        
                        Button {
                            editingIngredient = EditingIngredient(item)
                        } label: {
                            Image(systemName: "pencil.circle.fill")
                                .foregroundStyle(.blue)
                        }
                        
                        Button {
                            ingredientStore.deleteIngredient(item)
                            selectedIngredients.removeAll { $0.name == item }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.red)
                        }
                    }
                    .padding()
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    selectedItemsSection
                    availableItemsSection
                }
                .padding()
            }
            .background(Color(.systemGray6))
            .navigationTitle("Select Ingredients")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddNew = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddNew) {
                AddNewIngredientView(ingredientStore: ingredientStore)
            }
            .alert("Enter Amount", isPresented: $showingQuantityInput) {
                TextField("Amount", text: $tempAmount)
                    .keyboardType(.decimalPad)
                
                Picker("Unit", selection: $selectedUnit) {
                    ForEach(Ingredient.Unit.allCases, id: \.self) { unit in
                        HStack {
                            Text(unit.displayName)
                            Text("(\(unit.rawValue))")
                                .foregroundStyle(.secondary)
                        }
                        .tag(unit)
                    }
                }
                
                Button("Save") {
                    if let amount = Double(tempAmount) {
                        if let index = selectedIngredients.firstIndex(where: { $0.name == selectedName }) {
                            selectedIngredients[index].amount = amount
                            selectedIngredients[index].unit = selectedUnit
                        } else {
                            selectedIngredients.append(Ingredient(
                                name: selectedName,
                                amount: amount,
                                unit: selectedUnit
                            ))
                        }
                    }
                }
                
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Enter amount and unit for \(selectedName)")
            }
            .sheet(item: $editingIngredient) { item in
                EditIngredientView(
                    ingredientStore: ingredientStore,
                    originalName: item.id,
                    selectedIngredients: $selectedIngredients
                )
            }
        }
    }
} 