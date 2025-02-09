import Foundation

struct Ingredient: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var amount: Double
    var unit: Unit
    
    init(id: UUID = UUID(), name: String, amount: Double = 1.0, unit: Unit = .piece) {
        self.id = id
        self.name = name
        self.amount = amount
        self.unit = unit
    }
    
    enum Unit: String, CaseIterable, Codable {
        case piece = "pc"
        case gram = "g"
        case kilogram = "kg"
        case milliliter = "ml"
        case liter = "l"
        case tablespoon = "tbsp"
        case teaspoon = "tsp"
        case cup = "cup"
        
        var displayName: String {
            switch self {
            case .piece: return "Piece"
            case .gram: return "Gram"
            case .kilogram: return "Kilogram"
            case .milliliter: return "Milliliter"
            case .liter: return "Liter"
            case .tablespoon: return "Tablespoon"
            case .teaspoon: return "Teaspoon"
            case .cup: return "Cup"
            }
        }
    }
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Ingredient, rhs: Ingredient) -> Bool {
        lhs.id == rhs.id
    }
} 