import SwiftUI

struct KeyboardDismissModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scrollDismissesKeyboard(.interactively)
    }
}

extension View {
    func dismissKeyboardOnTap() -> some View {
        modifier(KeyboardDismissModifier())
    }
} 