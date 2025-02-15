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
    @State private var showingDebugInfo = false
    
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
        .onLongPress {
            showingDebugInfo = true
        }
        .sheet(isPresented: $showingDebugInfo) {
            DebugInfoView(
                recipeStore: recipeStore,
                shoppingListStore: shoppingListStore,
                recipeBookStore: recipeBookStore
            )
        }
    }
}

struct DebugInfoView: View {
    @ObservedObject var recipeStore: RecipeStore
    @ObservedObject var shoppingListStore: ShoppingListStore
    @ObservedObject var recipeBookStore: RecipeBookStore
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section("iCloud Status") {
                    if let url = recipeStore.iCloudURL {
                        Text("iCloud URL: \(url.path)")
                            .font(.caption)
                            .textSelection(.enabled)
                    } else {
                        Text("iCloud not available")
                            .foregroundStyle(.red)
                    }
                }
                
                Section("Recipes") {
                    Text("Count: \(recipeStore.recipes.count)")
                    ForEach(recipeStore.recipes) { recipe in
                        Text(recipe.name)
                            .font(.caption)
                    }
                }
                
                Section("Shopping List") {
                    Text("Count: \(shoppingListStore.items.count)")
                    ForEach(shoppingListStore.items) { item in
                        HStack {
                            Text(item.name)
                            Spacer()
                            Text("\(String(format: "%.1f", item.amount)) \(item.unit.rawValue)")
                        }
                        .font(.caption)
                    }
                }
                
                Section("Recipe Books") {
                    Text("Count: \(recipeBookStore.books.count)")
                    ForEach(recipeBookStore.books) { book in
                        VStack(alignment: .leading) {
                            Text(book.name)
                            Text("\(book.recipeIds.count) recipes")
                                .foregroundStyle(.secondary)
                        }
                        .font(.caption)
                    }
                }
            }
            .navigationTitle("Debug Info")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView(
        recipeStore: RecipeStore(),
        shoppingListStore: ShoppingListStore(),
        recipeBookStore: RecipeBookStore()
    )
}
