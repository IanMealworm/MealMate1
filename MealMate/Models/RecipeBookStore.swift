import Foundation

@MainActor
class RecipeBookStore: ObservableObject {
    @Published private(set) var books: [RecipeBook] = []
    private let filename = "SavedRecipeBooks.json"
    
    init() {
        if let loadedBooks = FileStorage.load([RecipeBook].self, from: filename) {
            books = loadedBooks
        }
    }
    
    func addBook(_ book: RecipeBook) {
        if book.exportedRecipes != nil {
            books.append(book)
        } else {
            var localBook = book
            localBook.recipeIds = book.recipeIds
            localBook.exportedRecipes = nil
            books.append(localBook)
        }
        save()
    }
    
    func deleteBook(_ book: RecipeBook) {
        books.removeAll { $0.id == book.id }
        save()
    }
    
    func updateBook(_ book: RecipeBook) {
        if let index = books.firstIndex(where: { $0.id == book.id }) {
            books[index] = book
            save()
        }
    }
    
    func addRecipeToBook(_ recipeId: UUID, bookId: UUID) {
        if let index = books.firstIndex(where: { $0.id == bookId }) {
            if books[index].exportedRecipes != nil {
                var localBook = books[index]
                localBook.recipeIds = localBook.exportedRecipes?.map { $0.id } ?? []
                localBook.exportedRecipes = nil
                books[index] = localBook
            }
            
            books[index].recipeIds.append(recipeId)
            save()
        }
    }
    
    func removeRecipeFromBook(_ recipeId: UUID, bookId: UUID) {
        if let index = books.firstIndex(where: { $0.id == bookId }) {
            if books[index].exportedRecipes != nil {
                var localBook = books[index]
                localBook.recipeIds = localBook.exportedRecipes?.map { $0.id } ?? []
                localBook.exportedRecipes = nil
                books[index] = localBook
            }
            
            books[index].recipeIds.removeAll { $0 == recipeId }
            save()
        }
    }
    
    private func save() {
        FileStorage.save(books, to: filename)
    }
} 