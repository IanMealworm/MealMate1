import SwiftUI
import UniformTypeIdentifiers

enum Tab {
    case recipes
    case shoppingList
}

struct ContentView: View {
    @ObservedObject var recipeStore: RecipeStore
    @ObservedObject var shoppingListStore: ShoppingListStore
    @State private var selectedTab: Tab = .recipes
    
    var body: some View {
        TabView(selection: $selectedTab) {
            RecipesView(
                recipeStore: recipeStore,
                shoppingListStore: shoppingListStore
            )
            .tabItem {
                Label("Recipes", systemImage: "book")
            }
            .tag(Tab.recipes)
            
            ShoppingListView(shoppingListStore: shoppingListStore)
                .tabItem {
                    Label("Shopping List", systemImage: "cart")
                }
                .tag(Tab.shoppingList)
        }
        .tint(.purple)
    }
}

#Preview {
    ContentView(
        recipeStore: RecipeStore(),
        shoppingListStore: ShoppingListStore()
    )
}
