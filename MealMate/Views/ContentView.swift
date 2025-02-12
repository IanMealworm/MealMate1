import SwiftUI
import UniformTypeIdentifiers

enum Tab {
    case recipes
    case books
    case shoppingList
}

struct ContentView: View {
    @ObservedObject var recipeStore: RecipeStore
    @ObservedObject var shoppingListStore: ShoppingListStore
    @ObservedObject var recipeBookStore: RecipeBookStore
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
            
            RecipeBooksView(
                recipeBookStore: recipeBookStore,
                recipeStore: recipeStore,
                shoppingListStore: shoppingListStore
            )
            .tabItem {
                Label("Books", systemImage: "books.vertical.fill")
            }
            .tag(Tab.books)
            
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
        shoppingListStore: ShoppingListStore(),
        recipeBookStore: RecipeBookStore()
    )
}
