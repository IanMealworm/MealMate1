import SwiftUI
import PhotosUI

struct AddInstructionStepView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var instructions: [String]
    @Binding var stepPhotos: [Int: Data]
    @Binding var stepIngredients: [Int: [Ingredient]]
    let ingredients: [Ingredient]
    let accentColor: Color
    
    @State private var instructionText = ""
    @State private var selectedIngredients: Set<Ingredient> = []
    
    // Photo handling states
    @State private var showingOptions = false
    @State private var showingCamera = false
    @State private var showingPhotoPicker = false
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedUIImage: UIImage?
    @State private var imageData: Data?
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    // Photo Section
                    Button {
                        showingOptions = true
                    } label: {
                        if let imageData,
                           let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        } else {
                            HStack {
                                Image(systemName: "camera")
                                Text("Add step photo")
                            }
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    .buttonStyle(.plain)
                }
                
                Section("Instruction") {
                    TextEditor(text: $instructionText)
                        .frame(minHeight: 100)
                }
                
                Section("Select Ingredients Used") {
                    ForEach(ingredients) { ingredient in
                        Button {
                            if selectedIngredients.contains(ingredient) {
                                selectedIngredients.remove(ingredient)
                            } else {
                                selectedIngredients.insert(ingredient)
                            }
                        } label: {
                            HStack {
                                Text("\(String(format: "%.1f", ingredient.amount)) \(ingredient.unit.rawValue) \(ingredient.name)")
                                Spacer()
                                if selectedIngredients.contains(ingredient) {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(accentColor)
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .navigationTitle("Add Step")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveStep()
                        dismiss()
                    }
                    .disabled(instructionText.isEmpty)
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
                    let croppedImage = cropToLandscape(image)
                    imageData = croppedImage.jpegData(compressionQuality: 0.8)
                }
            }
            .onChange(of: selectedItem) { newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        let croppedImage = cropToLandscape(uiImage)
                        imageData = croppedImage.jpegData(compressionQuality: 0.8)
                    }
                }
            }
        }
    }
    
    private func saveStep() {
        let stepIndex = instructions.count
        instructions.append(instructionText)
        
        if let imageData = imageData {
            stepPhotos[stepIndex] = imageData
        }
        
        if !selectedIngredients.isEmpty {
            stepIngredients[stepIndex] = Array(selectedIngredients)
        }
    }
    
    private func cropToLandscape(_ image: UIImage) -> UIImage {
        let targetAspectRatio: CGFloat = 16/9
        
        let imageWidth = image.size.width
        let imageHeight = image.size.height
        let imageAspectRatio = imageWidth / imageHeight
        
        if imageAspectRatio < targetAspectRatio {
            // Image is too tall, crop height
            let newHeight = imageWidth / targetAspectRatio
            let heightDifference = imageHeight - newHeight
            let cropRect = CGRect(x: 0, y: heightDifference/2, width: imageWidth, height: newHeight)
            if let cgImage = image.cgImage?.cropping(to: cropRect) {
                return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
            }
        } else if imageAspectRatio > targetAspectRatio {
            // Image is too wide, crop width
            let newWidth = imageHeight * targetAspectRatio
            let widthDifference = imageWidth - newWidth
            let cropRect = CGRect(x: widthDifference/2, y: 0, width: newWidth, height: imageHeight)
            if let cgImage = image.cgImage?.cropping(to: cropRect) {
                return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
            }
        }
        return image
    }
} 