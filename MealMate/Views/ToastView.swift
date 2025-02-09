import SwiftUI

struct ToastView: View {
    let message: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
            Text(message)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(radius: 5)
    }
} 