import SwiftUI

struct CroppedImageView: View {
    let imageData: Data
    let maxHeight: CGFloat
    
    var body: some View {
        if let uiImage = UIImage(data: imageData) {
            let croppedImage = cropToLandscape(uiImage)
            Image(uiImage: croppedImage)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: maxHeight)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                )
        }
    }
    
    private func cropToLandscape(_ image: UIImage) -> UIImage {
        let size = image.size
        if size.width >= size.height {
            return image // Already landscape or square
        }
        
        let targetAspect: CGFloat = 16/9
        let targetHeight = size.width / targetAspect
        let yOffset = (size.height - targetHeight) / 2
        
        let cropRect = CGRect(
            x: 0,
            y: yOffset,
            width: size.width,
            height: targetHeight
        )
        
        if let cgImage = image.cgImage?.cropping(to: cropRect) {
            return UIImage(cgImage: cgImage)
        }
        
        return image
    }
} 