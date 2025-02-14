import Foundation

@MainActor
class IngredientStore: ObservableObject {
    @Published private var savedIngredients: Set<String> = []
    @Published private var defaultUnits: [String: Ingredient.Unit] = [:]
    private let ingredientsKey = "SavedIngredients"
    private let defaultUnitsKey = "DefaultUnits"
    
    var ingredients: Set<String> { savedIngredients }
    var units: [String: Ingredient.Unit] { defaultUnits }
    
    nonisolated init() {
        Task { @MainActor in
            self.loadItems()
        }
    }
    
    func addIngredient(_ name: String, defaultUnit: Ingredient.Unit = .piece) {
        // Normalize the name by trimming whitespace and converting to title case
        let normalizedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
            .capitalized
        
        // Only add if it doesn't already exist
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
        
        // Only update if the new name doesn't already exist (unless it's the same as old name)
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