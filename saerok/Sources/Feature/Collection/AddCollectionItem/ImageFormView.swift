//
//  ImageFormView.swift
//  saerok
//
//  Created by HanSeung on 5/13/25.
//

import SwiftUI

extension CollectionFormView {
    struct ImageFormView: View {
        @Binding var selectedImage: UIImage?
        @State private var isShowingImagePicker: Bool = false

        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    if let image = selectedImage {
                        SelectedImageView(image: image) {
                            selectedImage = nil
                        }
                    } else {
                        ImageAddButton {
                            isShowingImagePicker = true
                        }
                    }
                }
                .padding(.vertical, 10)
            }
            .sheet(isPresented: $isShowingImagePicker) {
                ImagePicker(image: $selectedImage)
                    .presentationDetents([.medium, .large])
            }
        }

        private struct SelectedImageView: View {
            let image: UIImage
            let onDelete: () -> Void

            var body: some View {
                ZStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: Constants.imageSize, height: Constants.imageSize)
                        .clipped()
                        .cornerRadius(Constants.imageCornerRadius)

                    Button(action: onDelete) {
                        Image.SRIconSet.xmarkCircleFill.frame(.defaultIconSize)
                            .foregroundColor(.srGray)
                            .background(Color.srWhite)
                            .clipShape(Circle())
                            .offset(x: Constants.deleteButtonOffset, y: -Constants.deleteButtonOffset)
                    }
                }
            }
        }

        private struct ImageAddButton: View {
            let onTap: () -> Void

            var body: some View {
                Button {
                    onTap()
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: Constants.imageCornerRadius)
                            .stroke(Color.border, style: StrokeStyle(lineWidth: 1, dash: [5]))
                            .frame(width: Constants.imageSize, height: Constants.imageSize)
                        Image(systemName: "plus")
                            .foregroundColor(.border)
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}
