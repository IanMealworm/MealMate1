import SwiftUI
import PhotosUI

struct PhotoSectionView: View {
    @Binding var imageData: Data?
    @Binding var showingImageSource: Bool
    @Binding var selectedItem: PhotosPickerItem?
    @State private var showingCamera = false
    @State private var selectedUIImage: UIImage?
    @State private var showingOptions = false
    
    var body: some View {
        VStack(spacing: 12) {
            if let imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            Button {
                showingOptions = true
            } label: {
                Label("Add Photo", systemImage: "photo")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .foregroundStyle(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .confirmationDialog("Choose Photo Source", isPresented: $showingOptions, titleVisibility: .visible) {
            Button("Take Photo") {
                showingCamera = true
            }
            
            Button("Choose from Library") {
                selectedItem = nil  // Reset selection
                showingImageSource = true
            }
            
            Button("Cancel", role: .cancel) { }
        }
        .sheet(isPresented: $showingCamera, content: {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                ImagePicker(image: $selectedUIImage, sourceType: .camera)
                    .edgesIgnoringSafeArea(.all)
            }
            .presentationBackground(.clear)
        })
        .photosPicker(
            isPresented: $showingImageSource,
            selection: $selectedItem,
            matching: .images
        )
        .onChange(of: selectedUIImage) { newImage in
            if let image = newImage {
                let croppedImage = cropToLandscape(image)
                imageData = croppedImage.jpegData(compressionQuality: 0.8)
            }
        }
        .onChange(of: selectedItem) { newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    let croppedImage = cropToLandscape(uiImage)
                    imageData = croppedImage.jpegData(compressionQuality: 0.8)
                }
            }
        }
    }
    
    private func cropToLandscape(_ image: UIImage) -> UIImage {
        let targetAspectRatio: CGFloat = 16/9
        
        let imageWidth = image.size.width
        let imageHeight = image.size.height
        let imageAspectRatio = imageWidth / imageHeight
        
        if imageAspectRatio < targetAspectRatio {
            // Image is too tall, crop height
            let newHeight = imageWidth / targetAspectRatio
            let heightDifference = imageHeight - newHeight
            let cropRect = CGRect(x: 0, y: heightDifference/2, width: imageWidth, height: newHeight)
            if let cgImage = image.cgImage?.cropping(to: cropRect) {
                return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
            }
        } else if imageAspectRatio > targetAspectRatio {
            // Image is too wide, crop width
            let newWidth = imageHeight * targetAspectRatio
            let widthDifference = imageWidth - newWidth
            let cropRect = CGRect(x: widthDifference/2, y: 0, width: newWidth, height: imageHeight)
            if let cgImage = image.cgImage?.cropping(to: cropRect) {
                return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
            }
        }
        return image
    }
} 