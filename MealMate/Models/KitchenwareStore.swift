import Foundation

@MainActor
class KitchenwareStore: ObservableObject {
    @Published private(set) var items: [String]
    private let kitchenwareKey = "SavedKitchenware"
    
    init() {
        self.items = []
        loadItems()
    }
    
    func addItem(_ item: String) {
        items.append(item)
        saveItems()
    }
    
    func removeItem(_ item: String) {
        if let index = items.firstIndex(of: item) {
            items.remove(at: index)
            saveItems()
        }
    }
    
    func addKitchenware(_ name: String) {
        items.append(name)
        saveItems()
    }
    
    func updateKitchenware(oldName: String, newName: String) {
        if let index = items.firstIndex(of: oldName) {
            items[index] = newName
            saveItems()
        }
    }
    
    func deleteKitchenware(_ name: String) {
        items.removeAll { $0 == name }
        saveItems()
    }
    
    private func saveItems() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: kitchenwareKey)
        }
    }
    
    private func loadItems() {
        if let data = UserDefaults.standard.data(forKey: kitchenwareKey),
           let decoded = try? JSONDecoder().decode([String].self, from: data) {
            items = decoded
        }
    }
} 