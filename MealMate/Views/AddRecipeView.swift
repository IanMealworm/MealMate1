import SwiftUI
import PhotosUI

struct AddRecipeView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var recipeStore: RecipeStore
    
    // MARK: - State Properties
    @State private var name = ""
    @State private var description = ""
    @State private var cookTime = 30
    @State private var servings = 2
    @State private var ingredients: [Ingredient] = []
    @State private var instructions: [String] = []
    @State private var kitchenware: [String] = []
    @State private var selectedItem: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var showingImageSource = false
    @State private var selectedCategory: Recipe.Category = .dinner
    
    // Ingredient editing properties
    @State private var currentIngredient = ""
    @State private var tempAmount = ""
    @State private var selectedUnit: Ingredient.Unit = .piece
    @State private var showingAmountInput = false
    
    // MARK: - Object Properties
    @StateObject private var ingredientStore = IngredientStore()
    @StateObject private var kitchenwareStore = KitchenwareStore()
    
    // Add this property
    @State private var stepIngredients: [Int: [Ingredient]] = [:]
    @State private var stepPhotos: [Int: Data] = [:]
    
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
            .navigationTitle("New Recipe")
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
        let recipe = Recipe(
            name: name,
            description: description,
            ingredients: ingredients,
            instructions: instructions,
            cookTime: cookTime,
            servings: servings,
            kitchenware: kitchenware,
            imageData: imageData,
            category: selectedCategory,
            stepPhotos: stepPhotos,
            stepIngredients: stepIngredients
        )
        recipeStore.addRecipe(recipe)
        dismiss()
    }
} 