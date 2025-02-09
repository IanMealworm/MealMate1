import SwiftUI
import PhotosUI

struct StepByStepView: View {
    let recipe: Recipe
    let recipeStore: RecipeStore
    @State private var currentStep = 0
    @Environment(\.dismiss) var dismiss
    
    // Photo handling states
    @State private var showingOptions = false
    @State private var showingCamera = false
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedUIImage: UIImage?
    @State private var stepPhotos: [Int: Data]
    @State private var showingPhotoPicker = false
    
    init(recipe: Recipe, recipeStore: RecipeStore) {
        self.recipe = recipe
        self.recipeStore = recipeStore
        _stepPhotos = State(initialValue: recipe.stepPhotos)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Step Indicators
                HStack(spacing: 8) {
                    ForEach(0..<recipe.instructions.count, id: \.self) { index in
                        Capsule()
                            .fill(index == currentStep ? recipe.category.color : Color(.systemGray5))
                            .frame(height: 4)
                    }
                }
                .padding(.horizontal)
                
                // Photo Section
                Button {
                    showingOptions = true
                } label: {
                    if let photoData = stepPhotos[currentStep],
                       let uiImage = UIImage(data: photoData) {
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
                
                // Step Text and Ingredients
                VStack(alignment: .leading, spacing: 12) {
                    Text(recipe.instructions[currentStep])
                        .font(.title3)
                    
                    if let stepIngredients = recipe.stepIngredients[currentStep],
                       !stepIngredients.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Ingredients for this step:")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            ForEach(stepIngredients) { ingredient in
                                HStack {
                                    Image(systemName: "checkmark.circle")
                                        .foregroundStyle(.secondary)
                                    Text("\(String(format: "%.1f", ingredient.amount)) \(ingredient.unit.rawValue) \(ingredient.name)")
                                }
                                .font(.subheadline)
                            }
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(recipe.category.color.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Spacer()
            }
            .padding()
            .navigationTitle("Step \(currentStep + 1) of \(recipe.instructions.count)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        // Save photos before dismissing
                        let updatedRecipe = Recipe(
                            id: recipe.id,
                            name: recipe.name,
                            description: recipe.description,
                            ingredients: recipe.ingredients,
                            instructions: recipe.instructions,
                            cookTime: recipe.cookTime,
                            servings: recipe.servings,
                            isFavorite: recipe.isFavorite,
                            kitchenware: recipe.kitchenware,
                            imageData: recipe.imageData,
                            category: recipe.category,
                            stepPhotos: stepPhotos
                        )
                        recipeStore.updateRecipe(updatedRecipe)
                        dismiss()
                    }
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
                    stepPhotos[currentStep] = croppedImage.jpegData(compressionQuality: 0.8)
                }
            }
            .onChange(of: selectedItem) { newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        let croppedImage = cropToLandscape(uiImage)
                        stepPhotos[currentStep] = croppedImage.jpegData(compressionQuality: 0.8)
                    }
                }
            }
        }
        .contentShape(Rectangle()) // Makes the whole view swipeable
        .gesture(
            DragGesture(minimumDistance: 50)
                .onEnded { gesture in
                    let horizontalAmount = gesture.translation.width
                    if horizontalAmount > 0 && currentStep > 0 {
                        withAnimation {
                            currentStep -= 1
                        }
                    } else if horizontalAmount < 0 && currentStep < recipe.instructions.count - 1 {
                        withAnimation {
                            currentStep += 1
                        }
                    }
                }
        )
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