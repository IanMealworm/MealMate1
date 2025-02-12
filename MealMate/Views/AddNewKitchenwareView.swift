import SwiftUI

struct AddNewKitchenwareView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var kitchenwareStore: KitchenwareStore
    @State private var name = ""
    
    private var headerSection: some View {
        HStack {
            Image(systemName: "fork.knife")
                .foregroundStyle(.purple)
            Text("NEW KITCHENWARE")
                .foregroundStyle(.purple)
        }
        .font(.headline)
    }
    
    private var inputSection: some View {
        VStack(spacing: 12) {
            TextField("Name", text: $name)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 16) {
                        headerSection
                        inputSection
                    }
                    
                    ExistingKitchenwareSection(kitchenwareStore: kitchenwareStore)
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Add Kitchenware")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if !name.isEmpty {
                            kitchenwareStore.addKitchenware(name)
                            dismiss()
                        }
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

// Separate component for existing items
struct ExistingKitchenwareSection: View {
    @ObservedObject var kitchenwareStore: KitchenwareStore
    
    private var headerView: some View {
        HStack {
            Image(systemName: "list.bullet")
                .foregroundStyle(.purple)
            Text("EXISTING ITEMS")
                .foregroundStyle(.purple)
        }
        .font(.headline)
    }
    
    private var itemsList: some View {
        VStack(spacing: 12) {
            ForEach(kitchenwareStore.kitchenware, id: \.self) { item in
                KitchenwareItemRow(item: item, kitchenwareStore: kitchenwareStore)
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerView
            itemsList
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// Individual item row component
struct KitchenwareItemRow: View {
    let item: String
    @ObservedObject var kitchenwareStore: KitchenwareStore
    
    var body: some View {
        HStack {
            Text(item)
            Spacer()
            Button {
                kitchenwareStore.deleteKitchenware(item)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.red)
            }
        }
        .padding()
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
} 