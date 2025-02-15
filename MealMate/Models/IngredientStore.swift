import Foundation

@MainActor
class IngredientStore: ObservableObject {
    @Published private var savedIngredients: Set<String> = []
    @Published private var defaultUnits: [String: Ingredient.Unit] = [:]
    private let ingredientsKey = "SavedIngredients"
    private let defaultUnitsKey = "DefaultUnits"
    private let cloudStore = NSUbiquitousKeyValueStore.default
    
    var ingredients: Set<String> { savedIngredients }
    var units: [String: Ingredient.Unit] { defaultUnits }
    
    init() {
        setupCloudSync()
        loadItems()
    }
    
    private func setupCloudSync() {
        // Start monitoring iCloud changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCloudStoreChange),
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: cloudStore
        )
        
        // Trigger initial sync
        cloudStore.synchronize()
    }
    
    private func loadItems() {
        // Try loading from iCloud first
        if let cloudIngredients = cloudStore.array(forKey: ingredientsKey) as? [String] {
            savedIngredients = Set(cloudIngredients)
        }
        if let cloudUnitsData = cloudStore.data(forKey: defaultUnitsKey),
           let cloudUnits = try? JSONDecoder().decode([String: Ingredient.Unit].self, from: cloudUnitsData) {
            defaultUnits = cloudUnits
        }
        
        // Fallback to local storage if needed
        if savedIngredients.isEmpty {
            if let data = UserDefaults.standard.data(forKey: ingredientsKey),
               let decoded = try? JSONDecoder().decode([String].self, from: data) {
                savedIngredients = Set(decoded)
            }
        }
        
        if defaultUnits.isEmpty {
            if let data = UserDefaults.standard.data(forKey: defaultUnitsKey),
               let decoded = try? JSONDecoder().decode([String: Ingredient.Unit].self, from: data) {
                defaultUnits = decoded
            }
        }
    }
    
    private func saveItems() {
        // Save to iCloud
        cloudStore.set(Array(savedIngredients), forKey: ingredientsKey)
        if let unitsData = try? JSONEncoder().encode(defaultUnits) {
            cloudStore.set(unitsData, forKey: defaultUnitsKey)
        }
        cloudStore.synchronize()
        
        // Save locally as backup
        if let encodedIngredients = try? JSONEncoder().encode(Array(savedIngredients)) {
            UserDefaults.standard.set(encodedIngredients, forKey: ingredientsKey)
        }
        
        if let encodedUnits = try? JSONEncoder().encode(defaultUnits) {
            UserDefaults.standard.set(encodedUnits, forKey: defaultUnitsKey)
        }
    }
    
    @objc private func handleCloudStoreChange(_ notification: Notification) {
        loadItems()
        objectWillChange.send()
    }
    
    func addIngredient(_ name: String, defaultUnit: Ingredient.Unit = .piece) {
        let normalizedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
            .capitalized
        
        if !savedIngredients.contains(normalizedName) {
            savedIngredients.insert(normalizedName)
            defaultUnits[normalizedName] = defaultUnit
            saveItems()
            objectWillChange.send()
        }
    }
    
    func updateIngredient(oldName: String, newName: String, newUnit: Ingredient.Unit) {
        let normalizedNewName = newName.trimmingCharacters(in: .whitespacesAndNewlines)
            .capitalized
        
        if oldName.capitalized == normalizedNewName || !savedIngredients.contains(normalizedNewName) {
            savedIngredients.remove(oldName)
            savedIngredients.insert(normalizedNewName)
            defaultUnits.removeValue(forKey: oldName)
            defaultUnits[normalizedNewName] = newUnit
            saveItems()
            
            objectWillChange.send()
        }
    }
    
    func deleteIngredient(_ name: String) {
        savedIngredients.remove(name)
        defaultUnits.removeValue(forKey: name)
        saveItems()
        
        objectWillChange.send()
    }
} 