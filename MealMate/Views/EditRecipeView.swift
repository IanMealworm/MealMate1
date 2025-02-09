import SwiftUI
import PhotosUI

struct EditRecipeView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var recipeStore: RecipeStore
    let shoppingListStore: ShoppingListStore
    let recipe: Recipe
    
    // MARK: - State Properties
    @State private var name: String
    @State private var description: String
    @State private var cookTime: Int
    @State private var servings: Int
    @State private var ingredients: [Ingredient]
    @State private var instructions: [String]
    @State private var kitchenware: [String]
    @State private var selectedItem: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var showingImageSource = false
    @State private var selectedCategory: Recipe.Category
    @State private var dominantColor: Color = .gray
    @State private var stepIngredients: [Int: [Ingredient]]
    @State private var stepPhotos: [Int: Data]
    @State private var currentIngredient = ""
    @State private var tempAmount = ""
    @State private var selectedUnit: Ingredient.Unit = .piece
    @State private var showingAmountInput = false
    
    // MARK: - Object Properties
    @StateObject private var ingredientStore = IngredientStore()
    @StateObject private var kitchenwareStore = KitchenwareStore()
    
    init(recipeStore: RecipeStore, shoppingListStore: ShoppingListStore, recipe: Recipe) {
        self.recipeStore = recipeStore
        self.shoppingListStore = shoppingListStore
        self.recipe = recipe
        
        // Initialize state with recipe data
        _name = State(initialValue: recipe.name)
        _description = State(initialValue: recipe.description)
        _cookTime = State(initialValue: recipe.cookTime)
        _servings = State(initialValue: recipe.servings)
        _ingredients = State(initialValue: recipe.ingredients)
        _instructions = State(initialValue: recipe.instructions)
        _kitchenware = State(initialValue: recipe.kitchenware)
        _imageData = State(initialValue: recipe.imageData)
        _selectedCategory = State(initialValue: recipe.category)
        _stepIngredients = State(initialValue: recipe.stepIngredients)
        _stepPhotos = State(initialValue: recipe.stepPhotos)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Photo Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "photo.fill")
                                .foregroundStyle(.purple)
                            Text("PHOTO")
                                .foregroundStyle(.purple)
                        }
                        .font(.headline)
                        
                        PhotoSectionView(
                            imageData: $imageData,
                            showingImageSource: $showingImageSource,
                            selectedItem: $selectedItem
                        )
                        .padding()
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    // Basic Information Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundStyle(.purple)
                            Text("BASIC INFORMATION")
                                .foregroundStyle(.purple)
                        }
                        .font(.headline)
                        
                        VStack(spacing: 12) {
                            TextField("Recipe Name", text: $name)
                                .textFieldStyle(.roundedBorder)
                            
                            TextField("Description", text: $description, axis: .vertical)
                                .textFieldStyle(.roundedBorder)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(Recipe.Category.allCases, id: \.self) { category in
                                        Button {
                                            selectedCategory = category
                                        } label: {
                                            Label(category.rawValue, systemImage: category.icon)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 8)
                                                .background(selectedCategory == category ? category.color : .white)
                                                .foregroundStyle(selectedCategory == category ? .white : .primary)
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                            
                            HStack {
                                Label("Cook Time: \(cookTime) mins", systemImage: "clock")
                                Stepper("", value: $cookTime, in: 5...480, step: 5)
                            }
                            
                            HStack {
                                Label("Servings: \(servings)", systemImage: "person.2")
                                Stepper("", value: $servings, in: 1...50)
                            }
                        }
                        .padding()
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    // Kitchenware Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "fork.knife")
                                .foregroundStyle(.purple)
                            Text("KITCHENWARE")
                                .foregroundStyle(.purple)
                        }
                        .font(.headline)
                        
                        VStack(spacing: 12) {
                            ForEach(kitchenware, id: \.self) { item in
                                HStack {
                                    Text(item)
                                    Spacer()
                                    Button {
                                        if let index = kitchenware.firstIndex(of: item) {
                                            kitchenware.remove(at: index)
                                        }
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(.red)
                                    }
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            
                            NavigationLink {
                                KitchenwareSelectionView(
                                    kitchenwareStore: kitchenwareStore,
                                    selectedKitchenware: $kitchenware
                                )
                            } label: {
                                Label("Add Kitchenware", systemImage: "plus.circle.fill")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(.purple.opacity(0.1))
                                    .foregroundStyle(.purple)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                        .padding()
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    // Ingredients Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "carrot.fill")
                                .foregroundStyle(.purple)
                            Text("INGREDIENTS")
                                .foregroundStyle(.purple)
                        }
                        .font(.headline)
                        
                        VStack(spacing: 12) {
                            ForEach(ingredients) { ingredient in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(ingredient.name)
                                            .font(.subheadline)
                                        Text("\(String(format: "%.1f", ingredient.amount)) \(ingredient.unit.rawValue)")
                                            .font(.caption)
                                            .foregroundStyle(.purple)
                                    }
                                    
                                    Spacer()
                                    
                                    HStack(spacing: 12) {
                                        Button {
                                            currentIngredient = ingredient.name
                                            tempAmount = String(format: "%.1f", ingredient.amount)
                                            selectedUnit = ingredient.unit
                                            showingAmountInput = true
                                        } label: {
                                            Image(systemName: "pencil.circle.fill")
                                                .foregroundStyle(.blue)
                                        }
                                        
                                        Button {
                                            if let index = ingredients.firstIndex(of: ingredient) {
                                                ingredients.remove(at: index)
                                            }
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundStyle(.red)
                                        }
                                    }
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            
                            NavigationLink {
                                IngredientSelectionView(
                                    ingredientStore: ingredientStore,
                                    selectedIngredients: $ingredients
                                )
                            } label: {
                                Label("Add Ingredients", systemImage: "plus.circle.fill")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(.purple.opacity(0.1))
                                    .foregroundStyle(.purple)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                        .padding()
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    // Instructions Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "list.number")
                                .foregroundStyle(.purple)
                            Text("INSTRUCTIONS")
                                .foregroundStyle(.purple)
                        }
                        .font(.headline)
                        
                        VStack(spacing: 12) {
                            InstructionsListView(
                                instructions: $instructions,
                                stepPhotos: $stepPhotos,
                                stepIngredients: $stepIngredients,
                                ingredients: ingredients,
                                accentColor: selectedCategory.color
                            )
                        }
                        .padding()
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding()
            }
            .background(Color(.systemGray6))
            .navigationTitle("Edit Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveRecipe()
                    }
                    .disabled(name.isEmpty || ingredients.isEmpty || instructions.isEmpty)
                }
            }
        }
        .task {
            // Initial color extraction
            if let imageData = imageData,
               let uiImage = UIImage(data: imageData) {
                dominantColor = await extractColor(from: uiImage)
            }
        }
        .onChange(of: imageData) { newValue in
            Task {
                if let newValue,
                   let uiImage = UIImage(data: newValue) {
                    dominantColor = await extractColor(from: uiImage)
                }
            }
        }
        .alert("Edit \(currentIngredient)", isPresented: $showingAmountInput) {
            TextField("Amount", text: $tempAmount)
                .keyboardType(.decimalPad)
            
            Picker("Unit", selection: $selectedUnit) {
                ForEach(Ingredient.Unit.allCases, id: \.self) { unit in
                    Text(unit.displayName).tag(unit)
                }
            }
            
            Button("Save") {
                if let amount = Double(tempAmount),
                   let index = ingredients.firstIndex(where: { $0.name == currentIngredient }) {
                    ingredients[index] = Ingredient(
                        name: currentIngredient,
                        amount: amount,
                        unit: selectedUnit
                    )
                }
                tempAmount = ""
            }
            
            Button("Cancel", role: .cancel) {
                tempAmount = ""
            }
        } message: {
            Text("Enter amount and unit")
        }
    }
    
    private func saveRecipe() {
        let updatedRecipe = Recipe(
            id: recipe.id,
            name: name,
            description: description,
            ingredients: ingredients,
            instructions: instructions,
            cookTime: cookTime,
            servings: servings,
            isFavorite: recipe.isFavorite,
            kitchenware: kitchenware,
            imageData: imageData,
            category: selectedCategory,
            stepPhotos: stepPhotos,
            stepIngredients: stepIngredients
        )
        recipeStore.updateRecipe(updatedRecipe)
        dismiss()
    }
    
    private func extractColor(from image: UIImage) async -> Color {
        guard let cgImage = image.cgImage else { return .gray }
        
        let size = CGSize(width: 100, height: 100)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        
        let thumbnail = UIGraphicsImageRenderer(size: size, format: format).image { _ in
            UIImage(cgImage: cgImage).draw(in: CGRect(origin: .zero, size: size))
        }
        
        guard let pixelData = thumbnail.cgImage?.dataProvider?.data,
              let data = CFDataGetBytePtr(pixelData) else { return .gray }
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        
        let bytesPerPixel = 4
        let pixelCount = Int(size.width * size.height)
        
        for i in stride(from: 0, to: pixelCount * bytesPerPixel, by: bytesPerPixel) {
            red += CGFloat(data[i])
            green += CGFloat(data[i + 1])
            blue += CGFloat(data[i + 2])
        }
        
        red /= CGFloat(pixelCount * 255)
        green /= CGFloat(pixelCount * 255)
        blue /= CGFloat(pixelCount * 255)
        
        return Color(red: red, green: green, blue: blue)
    }
} 