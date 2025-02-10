import SwiftUI

struct EditShoppingItemView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var shoppingListStore: ShoppingListStore
    let item: ShoppingItem
    
    @State private var amount = ""
    @State private var unit: Ingredient.Unit
    
    init(shoppingListStore: ShoppingListStore, item: ShoppingItem) {
        self.shoppingListStore = shoppingListStore
        self.item = item
        _amount = State(initialValue: String(format: "%.1f", item.amount))
        _unit = State(initialValue: item.unit)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Text(item.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                HStack {
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                    
                    Picker("Unit", selection: $unit) {
                        ForEach(Ingredient.Unit.allCases, id: \.self) { unit in
                            Text(unit.displayName).tag(unit)
                        }
                    }
                }
            }
            .navigationTitle("Edit Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let amountValue = Double(amount) {
                            shoppingListStore.updateItem(
                                item,
                                newAmount: amountValue,
                                newUnit: unit
                            )
                            dismiss()
                        }
                    }
                    .disabled(amount.isEmpty)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color(.systemGroupedBackground))
        }
        .presentationDetents([.medium])
    }
} 