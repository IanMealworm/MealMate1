import Foundation
import SwiftUI

struct Recipe: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var description: String
    var ingredients: [Ingredient]
    var instructions: [String]
    var cookTime: Int // in minutes
    var servings: Int
    var isFavorite: Bool
    var kitchenware: [String]
    var imageData: Data?
    var category: Category
    var stepPhotos: [Int: Data]
    var stepIngredients: [Int: [Ingredient]] // Maps step index to ingredients
    
    enum Category: String, Codable, CaseIterable {
        case breakfast = "Breakfast"
        case lunch = "Lunch"
        case dinner = "Dinner"
        case dessert = "Dessert"
        case snack = "Snack"
        case drink = "Drink"
        
        var icon: String {
            switch self {
            case .breakfast: return "sun.and.horizon"
            case .lunch: return "sun.max"
            case .dinner: return "moon.stars"
            case .dessert: return "birthday.cake"
            case .snack: return "carrot"
            case .drink: return "cup.and.saucer"
            }
        }
        
        var color: Color {
            switch self {
            case .breakfast: return .orange
            case .lunch: return .blue
            case .dinner: return .purple
            case .dessert: return .pink
            case .snack: return .green
            case .drink: return .mint
            }
        }
    }
    
    init(id: UUID = UUID(), 
         name: String, 
         description: String = "",
         ingredients: [Ingredient] = [],
         instructions: [String] = [],
         cookTime: Int, 
         servings: Int, 
         isFavorite: Bool = false,
         kitchenware: [String] = [],
         imageData: Data? = nil,
         category: Category = .dinner,
         stepPhotos: [Int: Data] = [:],
         stepIngredients: [Int: [Ingredient]] = [:]) {
        self.id = id
        self.name = name
        self.description = description
        self.ingredients = ingredients
        self.instructions = instructions
        self.cookTime = cookTime
        self.servings = servings
        self.isFavorite = isFavorite
        self.kitchenware = kitchenware
        self.imageData = imageData
        self.category = category
        self.stepPhotos = stepPhotos
        self.stepIngredients = stepIngredients
    }
    
    static func == (lhs: Recipe, rhs: Recipe) -> Bool {
        lhs.id == rhs.id
    }
} 