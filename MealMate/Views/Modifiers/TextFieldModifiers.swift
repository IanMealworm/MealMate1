import SwiftUI

struct CapitalizedTextFieldStyle: ViewModifier {
    @Binding var text: String
    
    func body(content: Content) -> some View {
        content
            .textInputAutocapitalization(.words)
            .onChange(of: text) { newValue in
                if let firstChar = newValue.first {
                    text = String(firstChar).uppercased() + newValue.dropFirst()
                }
            }
    }
}

extension View {
    func capitalizedTextField(text: Binding<String>) -> some View {
        modifier(CapitalizedTextFieldStyle(text: text))
    }
} 