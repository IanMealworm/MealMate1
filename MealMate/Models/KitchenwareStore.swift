import Foundation

@MainActor
class KitchenwareStore: ObservableObject {
    @Published private var items: [String] = []
    private let kitchenwareKey = "SavedKitchenware"
    
    var kitchenware: [String] { items }
    
    nonisolated init() {
        Task { @MainActor in
            self.loadItems()
        }
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
        // Normalize the name by trimming whitespace and converting to title case
        let normalizedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
            .capitalized
        
        // Only add if it doesn't already exist
        if !items.contains(normalizedName) {
            items.append(normalizedName)
            saveItems()
        }
    }
    
    func updateKitchenware(oldName: String, newName: String) {
        let normalizedNewName = newName.trimmingCharacters(in: .whitespacesAndNewlines)
            .capitalized
        
        // Only update if the new name doesn't already exist (unless it's the same as old name)
        if oldName.capitalized == normalizedNewName || !items.contains(normalizedNewName) {
            if let index = items.firstIndex(of: oldName) {
                items[index] = normalizedNewName
                saveItems()
            }
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