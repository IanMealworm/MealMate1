import SwiftUI
import UniformTypeIdentifiers

struct RecipeBooksView: View {
    @ObservedObject var recipeBookStore: RecipeBookStore
    @ObservedObject var recipeStore: RecipeStore
    @ObservedObject var shoppingListStore: ShoppingListStore
    @State private var showingAddBook = false
    @State private var showingImporter = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Books Grid
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ],
                        spacing: 16
                    ) {
                        // Add Book Button
                        Button {
                            showingAddBook = true
                        } label: {
                            VStack(spacing: 12) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.largeTitle)
                                Text("New Book")
                                    .font(.headline)
                            }
                            .frame(height: 160)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.background)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .foregroundStyle(.purple)
                        
                        // Recipe Books
                        ForEach(recipeBookStore.books) { book in
                            NavigationLink(destination: RecipeBookDetailView(
                                book: book,
                                recipeBookStore: recipeBookStore,
                                recipeStore: recipeStore,
                                ingredientStore: recipeStore.ingredientStore,
                                kitchenwareStore: recipeStore.kitchenwareStore,
                                shoppingListStore: shoppingListStore
                            )) {
                                RecipeBookCard(book: book)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                Button(role: .destructive) {
                                    recipeBookStore.deleteBook(book)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Recipe Books")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            showingAddBook = true
                        } label: {
                            Label("New Book", systemImage: "plus")
                        }
                        
                        Button {
                            showingImporter = true
                        } label: {
                            Label("Import Book", systemImage: "square.and.arrow.down")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingAddBook) {
                AddRecipeBookView(recipeBookStore: recipeBookStore)
            }
            .fileImporter(
                isPresented: $showingImporter,
                allowedContentTypes: [UTType(filenameExtension: "mealmatebook")!],
                allowsMultipleSelection: true
            ) { result in
                switch result {
                case .success(let urls):
                    for url in urls {
                        guard url.startAccessingSecurityScopedResource() else {
                            print("Failed to access security scoped resource")
                            continue
                        }
                        
                        defer {
                            url.stopAccessingSecurityScopedResource()
                        }
                        
                        do {
                            let data = try Data(contentsOf: url)
                            let book = try JSONDecoder().decode(RecipeBook.self, from: data)
                            recipeBookStore.addBook(book)
                        } catch {
                            print("Error importing recipe book: \(error.localizedDescription)")
                        }
                    }
                case .failure(let error):
                    print("Error selecting files: \(error.localizedDescription)")
                }
            }
        }
    }
}

struct RecipeBookCard: View {
    let book: RecipeBook
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let imageData = book.imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 40))
                    .frame(height: 100)
                    .frame(maxWidth: .infinity)
                    .background(book.color.color.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(book.name)
                    .font(.headline)
                    .foregroundStyle(book.color.color)
                
                if !book.description.isEmpty {
                    Text(book.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
        }
        .frame(height: 160)
        .padding()
        .background(.background)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(book.color.color.opacity(0.3), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
} 