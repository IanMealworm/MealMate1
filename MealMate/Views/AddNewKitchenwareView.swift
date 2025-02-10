import SwiftUI

struct AddNewKitchenwareView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var kitchenwareStore: KitchenwareStore
    @State private var name = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Input Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "fork.knife")
                                .foregroundStyle(.purple)
                            Text("NEW KITCHENWARE")
                                .foregroundStyle(.purple)
                        }
                        .font(.headline)
                        
                        TextField("Name", text: $name)
                            .textFieldStyle(.roundedBorder)
                            .padding(.horizontal)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // Existing Items Section
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
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
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