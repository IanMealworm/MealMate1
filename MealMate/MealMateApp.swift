//
//  MealMateApp.swift
//  MealMate
//
//  Created by Reese Norton on 2/9/25.
//

import SwiftUI

@main
struct MealMateApp: App {
    @StateObject private var recipeStore = RecipeStore()
    @StateObject private var shoppingListStore = ShoppingListStore()
    @StateObject private var recipeBookStore = RecipeBookStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView(
                recipeStore: recipeStore,
                shoppingListStore: shoppingListStore,
                recipeBookStore: recipeBookStore
            )
            .onOpenURL { url in
                print("Attempting to open URL: \(url)")
                handleIncomingURL(url)
            }
        }
    }
    
    private func handleIncomingURL(_ url: URL) {
        print("Starting to handle URL: \(url)")
        
        // Copy file to temporary location
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(url.lastPathComponent)
        do {
            if FileManager.default.fileExists(atPath: tempURL.path) {
                try FileManager.default.removeItem(at: tempURL)
            }
            try FileManager.default.copyItem(at: url, to: tempURL)
            
            let data = try Data(contentsOf: tempURL)
            
            // Check file extension to determine type
            switch url.pathExtension.lowercased() {
            case "mealmate":
                let recipe = try JSONDecoder().decode(Recipe.self, from: data)
                Task { @MainActor in
                    recipeStore.addRecipe(recipe)
                    print("Successfully imported recipe: \(recipe.name)")
                }
                
            case "mealmatebook":
                let book = try JSONDecoder().decode(RecipeBook.self, from: data)
                Task { @MainActor in
                    recipeBookStore.addBook(book)
                    print("Successfully imported recipe book: \(book.name)")
                }
                
            default:
                print("Unsupported file type: \(url.pathExtension)")
            }
        } catch {
            print("Error handling incoming URL: \(error.localizedDescription)")
        }
    }
}
