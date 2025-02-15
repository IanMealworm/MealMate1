import Foundation
import SwiftUI

struct RecipeBook: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var recipeIds: [UUID]  // For internal use
    var imageData: Data?
    var color: RecipeBookColor
    var exportedRecipes: [Recipe]?
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, recipeIds, imageData, color, exportedRecipes
    }
    
    enum RecipeBookColor: String, Codable, CaseIterable {
        case red = "Red"
        case orange = "Orange"
        case yellow = "Yellow"
        case green = "Green"
        case blue = "Blue"
        case purple = "Purple"
        case pink = "Pink"
        
        var color: Color {
            switch self {
            case .red: return .red
            case .orange: return .orange
            case .yellow: return .yellow
            case .green: return .green
            case .blue: return .blue
            case .purple: return .purple
            case .pink: return .pink
            }
        }
    }
    
    init(
        id: UUID = UUID(),
        name: String,
        description: String = "",
        recipeIds: [UUID] = [],
        imageData: Data? = nil,
        color: RecipeBookColor = .blue,
        exportedRecipes: [Recipe]? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.recipeIds = recipeIds
        self.imageData = imageData
        self.color = color
        self.exportedRecipes = exportedRecipes
    }
} 