import SwiftUI

struct LongPressModifier: ViewModifier {
    let action: () -> Void
    
    func body(content: Content) -> some View {
        content.gesture(
            LongPressGesture(minimumDuration: 1)
                .onEnded { _ in
                    action()
                }
        )
    }
}

extension View {
    func onLongPress(perform action: @escaping () -> Void) -> some View {
        modifier(LongPressModifier(action: action))
    }
} 