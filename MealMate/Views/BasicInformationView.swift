import SwiftUI

struct BasicInformationView: View {
    @Binding var name: String
    @Binding var description: String
    @Binding var cookTime: Int
    @Binding var servings: Int
    @Binding var selectedCategory: Recipe.Category
    @FocusState private var focusedField: Field?
    
    enum Field {
        case name, description
    }
    
    var body: some View {
        Group {
            TextField("Recipe Name", text: $name)
                .focused($focusedField, equals: .name)
            
            TextField("Description", text: $description, axis: .vertical)
                .focused($focusedField, equals: .description)
            
            Picker("Category", selection: $selectedCategory) {
                ForEach(Recipe.Category.allCases, id: \.self) { category in
                    Label(category.rawValue, systemImage: category.icon)
                        .tag(category)
                }
            }
            
            Stepper("Cook Time: \(cookTime) mins", value: $cookTime, in: 5...480, step: 5)
            
            Stepper("Servings: \(servings)", value: $servings, in: 1...50)
        }
        .onTapGesture {
            focusedField = nil
        }
    }
} 