import SwiftUI
import PhotosUI

struct AddRecipeBookView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var recipeBookStore: RecipeBookStore
    
    @State private var name = ""
    @State private var description = ""
    @State private var selectedColor: RecipeBook.RecipeBookColor = .blue
    @State private var imageData: Data?
    @State private var selectedItem: PhotosPickerItem?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Photo Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "photo.fill")
                                .foregroundStyle(selectedColor.color)
                            Text("COVER PHOTO")
                                .foregroundStyle(selectedColor.color)
                        }
                        .font(.headline)
                        
                        PhotoSectionView(
                            imageData: $imageData,
                            showingImageSource: .constant(false),
                            selectedItem: $selectedItem
                        )
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    // Basic Info Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundStyle(selectedColor.color)
                            Text("BASIC INFORMATION")
                                .foregroundStyle(selectedColor.color)
                        }
                        .font(.headline)
                        
                        VStack(spacing: 12) {
                            TextField("Book Name", text: $name)
                                .textFieldStyle(.roundedBorder)
                            
                            TextField("Description", text: $description, axis: .vertical)
                                .textFieldStyle(.roundedBorder)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(RecipeBook.RecipeBookColor.allCases, id: \.self) { color in
                                        Button {
                                            selectedColor = color
                                        } label: {
                                            Circle()
                                                .fill(color.color)
                                                .frame(width: 40, height: 40)
                                                .overlay {
                                                    if selectedColor == color {
                                                        Image(systemName: "checkmark")
                                                            .foregroundStyle(.white)
                                                    }
                                                }
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("New Recipe Book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        let book = RecipeBook(
                            name: name,
                            description: description,
                            imageData: imageData,
                            color: selectedColor
                        )
                        recipeBookStore.addBook(book)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
} 