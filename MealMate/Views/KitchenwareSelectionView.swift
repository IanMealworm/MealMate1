import SwiftUI

struct KitchenwareSelectionView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var kitchenwareStore: KitchenwareStore
    @Binding var selectedKitchenware: [String]
    @State private var showingAddNew = false
    
    private var selectedItemsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.purple)
                Text("SELECTED ITEMS")
                    .foregroundStyle(.purple)
            }
            .font(.headline)
            
            if selectedKitchenware.isEmpty {
                Text("No items selected")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                VStack(spacing: 12) {
                    ForEach(selectedKitchenware, id: \.self) { item in
                        HStack {
                            Text(item)
                            Spacer()
                            Button {
                                selectedKitchenware.removeAll { $0 == item }
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
    }
    
    private var availableItemsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "fork.knife")
                    .foregroundStyle(.purple)
                Text("AVAILABLE ITEMS")
                    .foregroundStyle(.purple)
            }
            .font(.headline)
            
            VStack(spacing: 12) {
                ForEach(kitchenwareStore.items, id: \.self) { item in
                    Button {
                        if selectedKitchenware.contains(item) {
                            selectedKitchenware.removeAll { $0 == item }
                        } else {
                            selectedKitchenware.append(item)
                        }
                    } label: {
                        HStack {
                            Text(item)
                            Spacer()
                            Image(systemName: selectedKitchenware.contains(item) ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(selectedKitchenware.contains(item) ? .purple : .secondary)
                        }
                        .padding()
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    selectedItemsSection
                    availableItemsSection
                }
                .padding()
            }
            .background(Color(.systemGray6))
            .navigationTitle("Select Kitchenware")
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
                AddKitchenwareView(kitchenwareStore: kitchenwareStore)
            }
        }
    }
} 