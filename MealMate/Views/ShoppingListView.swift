import SwiftUI

struct ShoppingListView: View {
    @ObservedObject var shoppingListStore: ShoppingListStore
    @State private var showingAddItem = false
    @State private var showingCompleteConfirmation = false
    @State private var showingSortOptions = false
    @State private var showingClearConfirmation = false
    @State private var editingItem: ShoppingItem?
    @State private var sortOption: SortOption = .category
    
    enum SortOption {
        case category, name, checked
    }
    
    private var groupedItems: [(String, [ShoppingItem])] {
        let sorted = shoppingListStore.items.sorted { item1, item2 in
            switch sortOption {
            case .category:
                return item1.category.rawValue < item2.category.rawValue
            case .name:
                return item1.name < item2.name
            case .checked:
                if item1.isChecked == item2.isChecked {
                    return item1.name < item2.name
                }
                return !item1.isChecked && item2.isChecked
            }
        }
        
        let grouped = Dictionary(grouping: sorted) { item in
            switch sortOption {
            case .category:
                return item.category.rawValue
            case .name:
                return String(item.name.prefix(1)).uppercased()
            case .checked:
                return item.isChecked ? "Checked" : "Unchecked"
            }
        }
        
        return grouped.sorted { $0.key < $1.key }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {  // Added ZStack to ensure content doesn't overlap tab bar
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        if shoppingListStore.items.isEmpty {
                            ContentUnavailableView(
                                "No Items",
                                systemImage: "cart",
                                description: Text("Add items to your shopping list")
                            )
                        } else {
                            ForEach(groupedItems, id: \.0) { section, items in
                                VStack(alignment: .leading, spacing: 16) {
                                    // Section Header
                                    HStack {
                                        Image(systemName: "cart.fill")
                                            .foregroundStyle(.purple)
                                        Text(section.uppercased())
                                            .foregroundStyle(.purple)
                                    }
                                    .font(.headline)
                                    
                                    // Items
                                    VStack(spacing: 12) {
                                        ForEach(items) { item in
                                            ShoppingItemRow(item: item, onToggle: {
                                                shoppingListStore.toggleItem(item)
                                            }, onEdit: {
                                                editingItem = item
                                            })
                                        }
                                    }
                                }
                                .padding()
                                .background(Color(.tertiarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Shopping List")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Picker("Sort By", selection: $sortOption) {
                            Label("Category", systemImage: "folder").tag(SortOption.category)
                            Label("Name", systemImage: "textformat").tag(SortOption.name)
                            Label("Status", systemImage: "checkmark.circle").tag(SortOption.checked)
                        }
                        
                        if !shoppingListStore.items.isEmpty {
                            Divider()
                            
                            Button(role: .destructive) {
                                showingClearConfirmation = true
                            } label: {
                                Label("Clear All", systemImage: "trash")
                            }
                        }
                    } label: {
                        Label("More", systemImage: "ellipsis.circle")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddItem = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                
                if shoppingListStore.hasCheckedItems {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showingCompleteConfirmation = true
                        } label: {
                            Text("Complete")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddItem) {
                AddShoppingItemView(shoppingListStore: shoppingListStore)
            }
            .sheet(item: $editingItem) { item in
                EditShoppingItemView(
                    shoppingListStore: shoppingListStore,
                    item: item
                )
            }
            .alert("Complete Shopping", isPresented: $showingCompleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Complete", role: .destructive) {
                    shoppingListStore.completeShoppingRun()
                }
            } message: {
                Text("Are you sure you would like to complete this shopping run? This will remove all checked items from your list.")
            }
            .alert("Clear List", isPresented: $showingClearConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Clear All", role: .destructive) {
                    shoppingListStore.clearAll()
                }
            } message: {
                Text("Are you sure you want to clear your entire shopping list?")
            }
        }
    }
}

struct ShoppingItemRow: View {
    let item: ShoppingItem
    let onToggle: () -> Void
    let onEdit: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack {
                Image(systemName: item.isChecked ? "checkmark.square.fill" : "square")
                    .foregroundStyle(item.isChecked ? .green : .secondary)
                    .imageScale(.large)
                
                VStack(alignment: .leading) {
                    Text(item.name)
                        .strikethrough(item.isChecked)
                    
                    Text("\(String(format: "%.1f", item.amount)) \(item.unit.rawValue)")
                        .font(.caption)
                        .foregroundStyle(.purple)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Button(action: onEdit) {
                    Image(systemName: "pencil.circle.fill")
                        .foregroundStyle(.blue)
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ShoppingListView(shoppingListStore: ShoppingListStore())
} 