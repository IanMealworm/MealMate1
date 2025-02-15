import Foundation
import os

@MainActor
class ShoppingListStore: ObservableObject {
    @Published private(set) var items: [ShoppingItem] = []
    private let saveKey = "SavedShoppingList"
    private let cloudStore = NSUbiquitousKeyValueStore.default
    private let logger = Logger(subsystem: "com.yourcompany.MealMate", category: "ShoppingListStore")
    
    init() {
        setupCloudSync()
        loadItems()
    }
    
    private func setupCloudSync() {
        logger.info("Setting up iCloud sync for shopping list")
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCloudStoreChange),
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: cloudStore
        )
        
        cloudStore.synchronize()
        logger.info("Initial cloud sync triggered")
    }
    
    private func loadItems() {
        logger.info("Loading shopping list items")
        
        // Try loading from iCloud first
        if let cloudData = cloudStore.data(forKey: saveKey),
           let cloudItems = try? JSONDecoder().decode([ShoppingItem].self, from: cloudData) {
            self.items = cloudItems
            logger.info("Loaded \(self.items.count) items from iCloud")
            return
        }
        
        // Fallback to local storage
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([ShoppingItem].self, from: data) {
            self.items = decoded
            logger.info("Loaded \(self.items.count) items from local storage")
        } else {
            logger.warning("No shopping list items found in local storage")
        }
    }
    
    private func save() {
        logger.info("Saving shopping list with \(self.items.count) items")
        
        if let encoded = try? JSONEncoder().encode(self.items) {
            // Save to iCloud
            cloudStore.set(encoded, forKey: saveKey)
            cloudStore.synchronize()
            logger.info("Saved to iCloud")
            
            // Save locally as backup
            UserDefaults.standard.set(encoded, forKey: saveKey)
            logger.info("Saved to local storage")
        } else {
            logger.error("Failed to encode shopping list items")
        }
    }
    
    @objc private func handleCloudStoreChange(_ notification: Notification) {
        logger.info("Received iCloud change notification")
        if let userInfo = notification.userInfo {
            logger.info("Change details: \(userInfo)")
        }
        loadItems()
        objectWillChange.send()
    }
    
    func addItem(_ item: ShoppingItem) {
        logger.info("Adding item: \(item.name)")
        if let index = items.firstIndex(where: { $0.name == item.name && $0.unit == item.unit }) {
            // If item exists, add quantities
            var updatedItem = items[index]
            updatedItem.amount += item.amount
            items[index] = updatedItem
            logger.info("Updated existing item quantity")
        } else {
            // If item doesn't exist, add new item
            items.append(item)
            logger.info("Added new item")
        }
        save()
    }
    
    func addRecipeIngredients(_ ingredients: [Ingredient]) {
        logger.info("Adding ingredients from recipe")
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
    
    func toggleItem(_ item: ShoppingItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            var updatedItem = items[index]
            updatedItem.isChecked.toggle()
            items[index] = updatedItem
            logger.info("Toggled item: \(item.name)")
            save()
        }
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
            logger.info("Updated item: \(item.name)")
            save()
        }
    }
    
    func removeItem(_ item: ShoppingItem) {
        items.removeAll { $0.id == item.id }
        logger.info("Removed item: \(item.name)")
        save()
    }
    
    func completeShoppingRun() {
        let removedCount = items.filter { $0.isChecked }.count
        items.removeAll { $0.isChecked }
        logger.info("Completed shopping run, removed \(removedCount) items")
        save()
    }
    
    func clearAll() {
        items.removeAll()
        logger.info("Cleared all shopping list items")
        save()
    }
    
    var hasCheckedItems: Bool {
        items.contains { $0.isChecked }
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