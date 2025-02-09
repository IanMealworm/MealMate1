import Foundation

@MainActor
class ShoppingListStore: ObservableObject {
    @Published private(set) var items: [ShoppingItem] = []
    private let saveKey = "SavedShoppingList"
    
    init() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([ShoppingItem].self, from: data) {
            items = decoded
        }
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    func addItem(_ item: ShoppingItem) {
        if let index = items.firstIndex(where: { $0.name == item.name && $0.unit == item.unit }) {
            // If item exists, add quantities
            var updatedItem = items[index]
            updatedItem.amount += item.amount
            items[index] = updatedItem
        } else {
            // If item doesn't exist, add new item
            items.append(item)
        }
        save()
    }
    
    func toggleItem(_ item: ShoppingItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isChecked.toggle()
            save()
        }
    }
    
    func removeItem(_ item: ShoppingItem) {
        items.removeAll { $0.id == item.id }
        save()
    }
    
    func addRecipeIngredients(_ ingredients: [Ingredient]) {
        for ingredient in ingredients {
            let shoppingItem = ShoppingItem(
                name: ingredient.name,
                amount: ingredient.amount,
                unit: ingredient.unit,
                category: determineCategory(for: ingredient.name)
            )
            addItem(shoppingItem)
        }
    }
    
    func completeShoppingRun() {
        items.removeAll { $0.isChecked }
        save()
    }
    
    var hasCheckedItems: Bool {
        items.contains { $0.isChecked }
    }
    
    func updateItem(_ item: ShoppingItem, newAmount: Double, newUnit: Ingredient.Unit) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = ShoppingItem(
                id: item.id,
                name: item.name,
                amount: newAmount,
                unit: newUnit,
                isChecked: item.isChecked,
                category: item.category
            )
            save()
        }
    }
    
    func clearAll() {
        items.removeAll()
        save()
    }
    
    private func determineCategory(for ingredient: String) -> ShoppingItem.Category {
        let lowercased = ingredient.lowercased()
        
        if lowercased.contains("milk") || lowercased.contains("cheese") || lowercased.contains("yogurt") {
            return .dairy
        } else if lowercased.contains("apple") || lowercased.contains("banana") || lowercased.contains("lettuce") {
            return .produce
        } else if lowercased.contains("chicken") || lowercased.contains("beef") || lowercased.contains("fish") {
            return .meat
        } else if lowercased.contains("bread") || lowercased.contains("bun") || lowercased.contains("roll") {
            return .bakery
        } else if lowercased.contains("frozen") {
            return .frozen
        } else if lowercased.contains("juice") || lowercased.contains("soda") || lowercased.contains("water") {
            return .beverages
        }
        
        return .other
    }
} 