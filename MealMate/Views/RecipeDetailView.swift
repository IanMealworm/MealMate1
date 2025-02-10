import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct RecipeDetailView: View {
    @ObservedObject var recipeStore: RecipeStore
    let shoppingListStore: ShoppingListStore
    let recipe: Recipe
    @State private var showingStepByStep = false
    @State private var showingEditSheet = false
    @State private var showingToast = false
    @State private var showingShareSheet = false
    @State private var exportURL: URL?
    
    init(recipe: Recipe, recipeStore: RecipeStore, shoppingListStore: ShoppingListStore) {
        self.recipe = recipe
        self.recipeStore = recipeStore
        self.shoppingListStore = shoppingListStore
    }
    
    private var currentRecipe: Recipe {
        recipeStore.recipes.first { $0.id == recipe.id } ?? recipe
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Recipe Photo
                if let imageData = currentRecipe.imageData,
                   let uiImage = UIImage(data: imageData) {
                    ZStack(alignment: .bottomTrailing) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 200)
                            .clipped()
                        
                        // Favorite Button
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                recipeStore.toggleFavorite(currentRecipe)
                            }
                        } label: {
                            Image(systemName: currentRecipe.isFavorite ? "heart.fill" : "heart")
                                .font(.title2)
                                .foregroundStyle(currentRecipe.isFavorite ? .red : .white)
                                .padding(12)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                                .scaleEffect(currentRecipe.isFavorite ? 1.1 : 1.0)
                        }
                        .padding(16)
                    }
                }
                
                Text(currentRecipe.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 24) {
                    // Basic Information Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundStyle(currentRecipe.category.color)
                            Text("BASIC INFORMATION")
                                .foregroundStyle(currentRecipe.category.color)
                        }
                        .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 24) {
                                Label("\(currentRecipe.cookTime) min", systemImage: "clock")
                                Label("\(currentRecipe.servings) servings", systemImage: "person.2")
                                Label(currentRecipe.category.rawValue, systemImage: currentRecipe.category.icon)
                            }
                            .font(.body)
                            .foregroundStyle(.secondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    // Kitchenware Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "kitchen.utensils")
                                .foregroundStyle(currentRecipe.category.color)
                            Text("KITCHENWARE")
                                .foregroundStyle(currentRecipe.category.color)
                        }
                        .font(.headline)
                        
                        if currentRecipe.kitchenware.isEmpty {
                            Text("No kitchenware needed")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        } else {
                            VStack(spacing: 12) {
                                ForEach(currentRecipe.kitchenware, id: \.self) { item in
                                    HStack {
                                        Text(item)
                                        Spacer()
                                        Image(systemName: "checkmark.circle")
                                            .foregroundStyle(currentRecipe.category.color)
                                    }
                                    .padding()
                                    .background(Color(.tertiarySystemBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // Ingredients Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "carrot.fill")
                                .foregroundStyle(currentRecipe.category.color)
                            Text("INGREDIENTS")
                                .foregroundStyle(currentRecipe.category.color)
                            
                            Spacer()
                            
                            Button {
                                shoppingListStore.addRecipeIngredients(currentRecipe.ingredients)
                                withAnimation {
                                    showingToast = true
                                }
                                
                                // Hide toast after delay
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation {
                                        showingToast = false
                                    }
                                }
                            } label: {
                                Label("Add to List", systemImage: "cart.badge.plus")
                                    .font(.subheadline)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(currentRecipe.category.color)
                                    .foregroundStyle(.white)
                                    .clipShape(Capsule())
                            }
                        }
                        .font(.headline)
                        
                        VStack(spacing: 12) {
                            ForEach(currentRecipe.ingredients) { ingredient in
                                HStack {
                                    Text(ingredient.name)
                                        .font(.subheadline)
                                    Spacer()
                                    Text("\(String(format: "%.1f", ingredient.amount)) \(ingredient.unit.rawValue)")
                                        .font(.subheadline)
                                        .foregroundStyle(currentRecipe.category.color)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(.tertiarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // Instructions Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            HStack {
                                Image(systemName: "list.number")
                                    .foregroundStyle(currentRecipe.category.color)
                                Text("INSTRUCTIONS")
                                    .foregroundStyle(currentRecipe.category.color)
                            }
                            .font(.headline)
                            
                            Spacer()
                            
                            Button {
                                showingStepByStep = true
                            } label: {
                                Label("Step by Step", systemImage: "play.fill")
                                    .font(.subheadline)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(currentRecipe.category.color)
                                    .foregroundStyle(.white)
                                    .clipShape(Capsule())
                            }
                        }
                        
                        VStack(spacing: 16) {
                            ForEach(currentRecipe.instructions.indices, id: \.self) { index in
                                VStack(alignment: .leading, spacing: 12) {
                                    // Step Header
                                    Text("Step \(index + 1)")
                                        .font(.title3)
                                        .foregroundStyle(currentRecipe.category.color)
                                    
                                    // Step Content
                                    VStack(alignment: .leading, spacing: 16) {
                                        // Step Photo if exists
                                        if let photoData = currentRecipe.stepPhotos[index],
                                           let uiImage = UIImage(data: photoData) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(maxWidth: .infinity)
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                        }
                                        
                                        // Step Instructions
                                        Text(currentRecipe.instructions[index])
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        // Step Ingredients at bottom
                                        if let stepIngs = currentRecipe.stepIngredients[index],
                                           !stepIngs.isEmpty {
                                            Divider()
                                            
                                            VStack(alignment: .leading, spacing: 8) {
                                                Text("Ingredients for this step:")
                                                    .font(.subheadline)
                                                    .foregroundStyle(.secondary)
                                                
                                                ForEach(stepIngs) { ingredient in
                                                    HStack(spacing: 12) {
                                                        Image(systemName: "checkmark.circle.fill")
                                                            .foregroundStyle(currentRecipe.category.color)
                                                        Text("\(String(format: "%.1f", ingredient.amount)) \(ingredient.unit.rawValue) \(ingredient.name)")
                                                            .frame(maxWidth: .infinity, alignment: .leading)
                                                    }
                                                    .font(.subheadline)
                                                }
                                            }
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(Color(.secondarySystemBackground))
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                        }
                                    }
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        exportRecipe()
                    } label: {
                        Label("Export Recipe", systemImage: "square.and.arrow.up")
                    }
                    
                    Button("Edit") {
                        showingEditSheet = true
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingStepByStep) {
            StepByStepView(recipe: currentRecipe, recipeStore: recipeStore)
        }
        .sheet(isPresented: $showingEditSheet) {
            EditRecipeView(
                recipeStore: recipeStore,
                shoppingListStore: shoppingListStore,
                recipe: currentRecipe
            )
        }
        .sheet(isPresented: $showingShareSheet) {
            if let url = exportURL {
                ShareSheet(items: [url])
            }
        }
        .overlay(alignment: .bottom) {
            if showingToast {
                ToastView(
                    message: "Added ingredients to shopping list",
                    icon: "checkmark.circle.fill"
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .padding(.bottom, 32)
            }
        }
    }
    
    private func exportRecipe() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(currentRecipe)
            
            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(currentRecipe.name.replacingOccurrences(of: " ", with: "_"))
                .appendingPathExtension("mealmate")
            
            try data.write(to: tempURL)
            
            let activityVC = UIActivityViewController(
                activityItems: [tempURL],
                applicationActivities: nil
            )
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootVC = window.rootViewController {
                activityVC.popoverPresentationController?.sourceView = rootVC.view
                rootVC.present(activityVC, animated: true)
            }
        } catch {
            print("Error exporting recipe: \(error.localizedDescription)")
        }
    }
} 