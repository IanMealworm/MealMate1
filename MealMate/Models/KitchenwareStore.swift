import Foundation

@MainActor
class KitchenwareStore: ObservableObject {
    @Published private var items: [String] = []
    private let kitchenwareKey = "SavedKitchenware"
    private let cloudStore = NSUbiquitousKeyValueStore.default
    
    var kitchenware: [String] { items }
    
    init() {
        setupCloudSync()
        loadItems()
    }
    
    private func setupCloudSync() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCloudStoreChange),
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: cloudStore
        )
        
        cloudStore.synchronize()
    }
    
    private func loadItems() {
        // Try loading from iCloud first
        if let cloudItems = cloudStore.array(forKey: kitchenwareKey) as? [String] {
            items = cloudItems
        }
        
        // Fallback to local storage if needed
        if items.isEmpty {
            if let data = UserDefaults.standard.data(forKey: kitchenwareKey),
               let decoded = try? JSONDecoder().decode([String].self, from: data) {
                items = decoded
            }
        }
    }
    
    private func saveItems() {
        // Save to iCloud
        cloudStore.set(items, forKey: kitchenwareKey)
        cloudStore.synchronize()
        
        // Save locally as backup
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: kitchenwareKey)
        }
    }
    
    @objc private func handleCloudStoreChange(_ notification: Notification) {
        loadItems()
        objectWillChange.send()
    }
    
    func addKitchenware(_ name: String) {
        let normalizedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
            .capitalized
        
        if !items.contains(normalizedName) {
            items.append(normalizedName)
            saveItems()
        }
    }
    
    func updateKitchenware(oldName: String, newName: String) {
        let normalizedNewName = newName.trimmingCharacters(in: .whitespacesAndNewlines)
            .capitalized
        
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
} 