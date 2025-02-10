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
    
    var body: some Scene {
        WindowGroup {
            ContentView(
                recipeStore: recipeStore,
                shoppingListStore: shoppingListStore
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
            let recipe = try JSONDecoder().decode(Recipe.self, from: data)
            
            Task { @MainActor in
                recipeStore.addRecipe(recipe)
                print("Successfully imported recipe: \(recipe.name)")
            }
        } catch {
            print("Error handling incoming URL: \(error.localizedDescription)")
        }
    }
}
