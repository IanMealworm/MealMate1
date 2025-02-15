import Foundation
import SwiftUI
import os

@MainActor
class RecipeBookStore: ObservableObject {
    @Published private(set) var books: [RecipeBook] = []
    
    private let fileManager = FileManager.default
    private var documentsURL: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    var iCloudURL: URL? {
        fileManager.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Books")
    }
    
    private let logger = Logger(subsystem: "com.yourcompany.MealMate", category: "RecipeBookStore")
    
    init() {
        setupiCloudDocuments()
        Task {
            await loadBooks()
        }
    }
    
    private func setupiCloudDocuments() {
        logger.info("Setting up iCloud Documents for recipe books...")
        
        if let iCloudDocsURL = iCloudURL {
            logger.info("iCloud URL available: \(iCloudDocsURL.path)")
            do {
                try fileManager.createDirectory(at: iCloudDocsURL, withIntermediateDirectories: true)
                logger.info("Successfully created iCloud directory for books")
            } catch {
                logger.error("Error creating iCloud directory: \(error.localizedDescription)")
            }
        } else {
            logger.warning("iCloud URL not available. Check iCloud settings and entitlements.")
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleiCloudChanges),
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: nil
        )
        logger.info("Added iCloud change observer")
    }
    
    private func loadBooks() async {
        logger.info("Starting recipe books load...")
        
        if let iCloudDocsURL = iCloudURL {
            do {
                let files = try fileManager.contentsOfDirectory(
                    at: iCloudDocsURL,
                    includingPropertiesForKeys: nil
                ).filter { $0.pathExtension == "mealmatebook" }
                
                logger.info("Found \(files.count) recipe books in iCloud")
                
                var loadedBooks: [RecipeBook] = []
                for fileURL in files {
                    do {
                        if let book = try? loadBook(from: fileURL) {
                            loadedBooks.append(book)
                            logger.info("Loaded book: \(book.name)")
                        }
                    } catch {
                        logger.error("Error loading book from \(fileURL.lastPathComponent): \(error.localizedDescription)")
                    }
                }
                
                await MainActor.run {
                    self.books = loadedBooks
                    logger.info("Updated books array with \(loadedBooks.count) books")
                }
                return
            } catch {
                logger.error("Error accessing iCloud directory: \(error.localizedDescription)")
            }
        } else {
            logger.warning("iCloud not available, falling back to local storage")
        }
        
        // Fallback to local storage
        if let loadedBooks = FileStorage.load([RecipeBook].self, from: "SavedRecipeBooks.json") {
            await MainActor.run {
                self.books = loadedBooks
                logger.info("Loaded \(loadedBooks.count) books from local storage")
            }
        } else {
            logger.warning("No recipe books found in local storage")
        }
    }
    
    private func loadBook(from url: URL) throws -> RecipeBook {
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(RecipeBook.self, from: data)
    }
    
    private func saveBook(_ book: RecipeBook) throws {
        logger.info("Saving book: \(book.name)")
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(book)
        
        if let iCloudDocsURL = iCloudURL {
            let fileURL = iCloudDocsURL.appendingPathComponent("\(book.id.uuidString).mealmatebook")
            try data.write(to: fileURL)
            logger.info("Saved book to iCloud: \(fileURL.lastPathComponent)")
        } else {
            logger.warning("iCloud not available, saving only locally")
        }
        
        FileStorage.save(books, to: "SavedRecipeBooks.json")
        logger.info("Saved book to local storage")
    }
    
    func addBook(_ book: RecipeBook) {
        books.append(book)
        
        do {
            try saveBook(book)
        } catch {
            logger.error("Error saving book: \(error.localizedDescription)")
        }
    }
    
    func updateBook(_ book: RecipeBook) {
        if let index = books.firstIndex(where: { $0.id == book.id }) {
            books[index] = book
            
            do {
                try saveBook(book)
            } catch {
                logger.error("Error updating book: \(error.localizedDescription)")
            }
        }
    }
    
    func deleteBook(_ book: RecipeBook) {
        books.removeAll { $0.id == book.id }
        
        if let iCloudDocsURL = iCloudURL {
            let fileURL = iCloudDocsURL.appendingPathComponent("\(book.id.uuidString).mealmatebook")
            try? fileManager.removeItem(at: fileURL)
            logger.info("Deleted book from iCloud: \(book.name)")
        }
        
        FileStorage.save(books, to: "SavedRecipeBooks.json")
        logger.info("Updated local storage after deleting book: \(book.name)")
    }
    
    @objc private func handleiCloudChanges(_ notification: Notification) {
        logger.info("Received iCloud change notification")
        if let userInfo = notification.userInfo {
            logger.info("Change details: \(userInfo)")
        }
        Task {
            await loadBooks()
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
            saveLocally()
        }
    }
    
    func removeRecipeFromBook(_ recipeId: UUID, bookId: UUID) {
        if let index = books.firstIndex(where: { $0.id == bookId }) {
            var book = books[index]
            
            if book.exportedRecipes != nil {
                book.exportedRecipes?.removeAll { $0.id == recipeId }
                books[index] = book
            } else {
                book.recipeIds.removeAll { $0 == recipeId }
                books[index] = book
            }
            
            saveLocally()
        }
    }
    
    private func saveLocally() {
        FileStorage.save(books, to: "SavedRecipeBooks.json")
    }
} 