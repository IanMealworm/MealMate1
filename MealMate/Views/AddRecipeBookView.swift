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
    
    @State private var showingOptions = false
    @State private var showingCamera = false
    @State private var selectedUIImage: UIImage?
    @State private var showingPhotoPicker = false
    
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
                        
                        VStack(spacing: 12) {
                            if let imageData,
                               let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 200)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            
                            Button {
                                showingOptions = true
                            } label: {
                                Label("Add Photo", systemImage: "photo")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundStyle(.blue)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
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
            .confirmationDialog("Choose Photo Source", isPresented: $showingOptions, titleVisibility: .visible) {
                Button("Take Photo") {
                    showingCamera = true
                }
                
                Button("Choose from Library") {
                    showingPhotoPicker = true
                }
                
                Button("Cancel", role: .cancel) { }
            }
            .sheet(isPresented: $showingCamera) {
                ZStack {
                    Color.black.edgesIgnoringSafeArea(.all)
                    ImagePicker(image: $selectedUIImage, sourceType: .camera)
                        .edgesIgnoringSafeArea(.all)
                }
                .presentationBackground(.clear)
            }
            .photosPicker(
                isPresented: $showingPhotoPicker,
                selection: $selectedItem,
                matching: .images
            )
            .onChange(of: selectedUIImage) { newImage in
                if let image = newImage {
                    imageData = image.jpegData(compressionQuality: 0.8)
                }
            }
            .onChange(of: selectedItem) { newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self) {
                        await MainActor.run {
                            imageData = data
                        }
                    }
                }
            }
        }
    }
} 