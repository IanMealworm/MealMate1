import SwiftUI

struct EditingIngredient: Identifiable {
    let id: String
    
    init(_ name: String) {
        self.id = name
    }
}

struct IngredientSelectionView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var ingredientStore: IngredientStore
    @Binding var selectedIngredients: [Ingredient]
    @State private var showingAddNew = false
    @State private var showingAmountPrompt = false
    @State private var selectedName = ""
    @State private var editingIngredient: EditingIngredient?
    
    private var headerSection: some View {
        HStack {
            Image(systemName: "carrot.fill")
                .foregroundStyle(.purple)
            Text("SELECT INGREDIENTS")
                .foregroundStyle(.purple)
        }
        .font(.headline)
    }
    
    private var selectedIngredientsSection: some View {
        VStack(spacing: 12) {
            ForEach(selectedIngredients) { ingredient in
                HStack {
                    Text(ingredient.name)
                    Spacer()
                    Text("\(String(format: "%.1f", ingredient.amount)) \(ingredient.unit.rawValue)")
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(Color(.tertiarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
    
    private var availableIngredientsSection: some View {
        VStack(spacing: 12) {
            ForEach(Array(ingredientStore.ingredients), id: \.self) { name in
                if !selectedIngredients.contains(where: { $0.name == name }) {
                    Button {
                        selectedName = name
                        showingAmountPrompt = true
                    } label: {
                        HStack {
                            Text(name)
                            Spacer()
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(.purple)
                        }
                        .padding()
                        .background(Color(.tertiarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 16) {
                        headerSection
                        selectedIngredientsSection
                        availableIngredientsSection
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Add Ingredients")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddNew = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddNew) {
                AddNewIngredientView(ingredientStore: ingredientStore)
            }
            .alert("Add Amount", isPresented: $showingAmountPrompt) {
                AmountPromptView(
                    selectedName: selectedName,
                    ingredientStore: ingredientStore,
                    selectedIngredients: $selectedIngredients
                )
            }
        }
    }
}

struct AmountPromptView: View {
    let selectedName: String
    let ingredientStore: IngredientStore
    @Binding var selectedIngredients: [Ingredient]
    @State private var amount = ""
    
    var body: some View {
        TextField("Amount", text: $amount)
            .keyboardType(.decimalPad)
        
        Button("Add") {
            if let amountValue = Double(amount) {
                let unit = ingredientStore.units[selectedName] ?? .piece
                let ingredient = Ingredient(name: selectedName, amount: amountValue, unit: unit)
                selectedIngredients.append(ingredient)
            }
        }
        
        Button("Cancel", role: .cancel) { }
    }
} 