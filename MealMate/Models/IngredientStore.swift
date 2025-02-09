import Foundation

@MainActor
class IngredientStore: ObservableObject {
    @Published private(set) var savedIngredients: Set<String> = []
    @Published private(set) var defaultUnits: [String: Ingredient.Unit] = [:]
    private let ingredientsKey = "SavedIngredients"
    private let defaultUnitsKey = "DefaultUnits"
    
    init() {
        loadItems()
    }
    
    func addIngredient(_ name: String, defaultUnit: Ingredient.Unit = .piece) {
        savedIngredients.insert(name)
        defaultUnits[name] = defaultUnit
        saveItems()
        objectWillChange.send()
    }
    
    func updateIngredient(oldName: String, newName: String, newUnit: Ingredient.Unit) {
        savedIngredients.remove(oldName)
        savedIngredients.insert(newName)
        defaultUnits.removeValue(forKey: oldName)
        defaultUnits[newName] = newUnit
        saveItems()
        objectWillChange.send()
    }
    
    func deleteIngredient(_ name: String) {
        savedIngredients.remove(name)
        defaultUnits.removeValue(forKey: name)
        saveItems()
        objectWillChange.send()
    }
    
    private func saveItems() {
        if let encodedIngredients = try? JSONEncoder().encode(Array(savedIngredients)) {
            UserDefaults.standard.set(encodedIngredients, forKey: ingredientsKey)
        }
        
        if let encodedUnits = try? JSONEncoder().encode(defaultUnits) {
            UserDefaults.standard.set(encodedUnits, forKey: defaultUnitsKey)
        }
    }
    
    private func loadItems() {
        if let data = UserDefaults.standard.data(forKey: ingredientsKey),
           let decoded = try? JSONDecoder().decode([String].self, from: data) {
            savedIngredients = Set(decoded)
        }
        
        if let data = UserDefaults.standard.data(forKey: defaultUnitsKey),
           let decoded = try? JSONDecoder().decode([String: Ingredient.Unit].self, from: data) {
            defaultUnits = decoded
        }
    }
} 