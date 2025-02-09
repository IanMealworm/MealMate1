import Foundation

struct ShoppingItem: Identifiable, Codable {
    let id: UUID
    var name: String
    var amount: Double
    var unit: Ingredient.Unit
    var isChecked: Bool
    var category: Category
    
    enum Category: String, Codable, CaseIterable {
        case produce = "Produce"
        case dairy = "Dairy"
        case meat = "Meat"
        case pantry = "Pantry"
        case frozen = "Frozen"
        case bakery = "Bakery"
        case beverages = "Beverages"
        case other = "Other"
    }
    
    init(
        id: UUID = UUID(),
        name: String,
        amount: Double,
        unit: Ingredient.Unit,
        isChecked: Bool = false,
        category: Category = .other
    ) {
        self.id = id
        self.name = name
        self.amount = amount
        self.unit = unit
        self.isChecked = isChecked
        self.category = category
    }
} 