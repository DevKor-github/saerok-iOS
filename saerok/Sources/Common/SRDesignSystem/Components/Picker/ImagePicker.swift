//
//  ImagePicker.swift
//  saerok
//
//  Created by HanSeung on 4/27/25.
//
//
//


import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var isLoading: Bool
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        config.preferredAssetRepresentationMode = .current
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard let provider = results.first?.itemProvider else {
                Task { @MainActor in
                    self.parent.isLoading = false
                }
                return
            }
            
            Task { @MainActor in
                self.parent.isLoading = true
            }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, error in
                    if let uiImage = image as? UIImage {
                        Task { @MainActor in
                            self.parent.image = uiImage
                            self.parent.isLoading = false
                        }
                    } else {
                        self.loadImageWithFileRepresentation(provider: provider)
                    }
                }
            } else {
                loadImageWithFileRepresentation(provider: provider)
            }
        }
        
        private func loadImageWithFileRepresentation(provider: NSItemProvider) {
            let typeIdentifier = UTType.image.identifier
            
            if provider.hasItemConformingToTypeIdentifier(typeIdentifier) {
                provider.loadFileRepresentation(forTypeIdentifier: typeIdentifier) { url, error in
                    guard let url = url else {
                        Task { @MainActor in
                            self.parent.isLoading = false
                        }
                        return
                    }
                    
                    do {
                        let data = try Data(contentsOf: url)
                        if let image = UIImage(data: data) {
                            Task { @MainActor in
                                self.parent.image = image
                                self.parent.isLoading = false
                            }
                        } else {
                            Task { @MainActor in
                                self.parent.isLoading = false
                            }
                        }
                    } catch {
                        Task { @MainActor in
                            self.parent.isLoading = false
                        }
                    }
                }
            } else {
                Task { @MainActor in
                    self.parent.isLoading = false
                }
            }
        }
    }
}

extension ImagePicker {
    func checkPhotoLibraryPermission() async -> Bool {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch status {
        case .notDetermined:
            let newStatus = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
            return newStatus == .authorized || newStatus == .limited
        case .denied, .restricted:
            print("⚠️ 사진 라이브러리 접근 권한이 거부되었습니다")
            return false
        case .authorized, .limited:
            return true
        @unknown default:
            return false
        }
    }
}
