import SwiftUI

struct AddShoppingItemView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var shoppingListStore: ShoppingListStore
    @StateObject private var ingredientStore = IngredientStore()
    
    @State private var name = ""
    @State private var amount = ""
    @State private var unit: Ingredient.Unit = .piece
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Item Name", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .capitalizedTextField(text: $name)
                
                HStack {
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                    
                    Picker("Unit", selection: $unit) {
                        ForEach(Ingredient.Unit.allCases, id: \.self) { unit in
                            Text(unit.displayName).tag(unit)
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        if let amountValue = Double(amount), !name.isEmpty {
                            let item = ShoppingItem(
                                name: name,
                                amount: amountValue,
                                unit: unit
                            )
                            shoppingListStore.addItem(item)
                            dismiss()
                        }
                    }
                    .disabled(name.isEmpty || amount.isEmpty)
                }
            }
        }
    }
} 