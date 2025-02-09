import SwiftUI

struct EditKitchenwareView: View {
    @ObservedObject var kitchenwareStore: KitchenwareStore
    let kitchenwareName: String
    @Binding var isPresented: Bool
    
    @State private var newName: String
    
    init(kitchenwareStore: KitchenwareStore, kitchenwareName: String, isPresented: Binding<Bool>) {
        self.kitchenwareStore = kitchenwareStore
        self.kitchenwareName = kitchenwareName
        self._isPresented = isPresented
        _newName = State(initialValue: kitchenwareName)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Kitchenware Name", text: $newName)
            }
            .dismissKeyboardOnTap()
            .navigationTitle("Edit Kitchenware")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        kitchenwareStore.updateKitchenware(
                            oldName: kitchenwareName,
                            newName: newName
                        )
                        isPresented = false
                    }
                    .disabled(newName.isEmpty || newName == kitchenwareName)
                }
            }
        }
        .presentationDetents([.medium])
    }
} 