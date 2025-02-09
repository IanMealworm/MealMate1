import SwiftUI

struct SectionHeader: View {
    let title: String
    let icon: String
    let color: Color
    var trailingContent: (() -> AnyView)? = nil
    
    var body: some View {
        HStack {
            Label(title, systemImage: icon)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(color)
            
            if let trailingContent {
                Spacer()
                trailingContent()
            }
        }
        .padding(.vertical, 8)
    }
} 