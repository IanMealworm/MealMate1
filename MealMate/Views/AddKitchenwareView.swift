import SwiftUI

struct AddKitchenwareView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var kitchenwareStore: KitchenwareStore
    @State private var name = ""
    
    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "fork.knife")
                    .foregroundStyle(.purple)
                Text("NEW KITCHENWARE")
                    .foregroundStyle(.purple)
            }
            .font(.headline)
            
            VStack(spacing: 12) {
                TextField("Name", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
            }
            .padding()
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    private var existingItemsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "list.bullet")
                    .foregroundStyle(.purple)
                Text("EXISTING ITEMS")
                    .foregroundStyle(.purple)
            }
            .font(.headline)
            
            VStack(spacing: 12) {
                ForEach(kitchenwareStore.items, id: \.self) { item in
                    HStack {
                        Text(item)
                        Spacer()
                        Button {
                            kitchenwareStore.removeItem(item)
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.red)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding()
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    inputSection
                    existingItemsSection
                }
                .padding()
            }
            .background(Color(.systemGray6))
            .navigationTitle("Add Kitchenware")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if !name.isEmpty {
                            kitchenwareStore.addItem(name)
                            dismiss()
                        }
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
} 