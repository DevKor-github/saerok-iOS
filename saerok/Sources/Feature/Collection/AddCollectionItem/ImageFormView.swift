//
//  ImageFormView.swift
//  saerok
//
//  Created by HanSeung on 5/13/25.
//


import SwiftUI

extension AddCollectionItemView {
    struct ImageFormView: View {
        @Binding var selectedImages: [UIImage]
        @State var isShowingImagePicker: Bool = false

        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(Array(selectedImages.enumerated()), id: \.offset) { index, image in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: Constants.imageSize, height: Constants.imageSize)
                                .clipped()
                                .cornerRadius(Constants.imageCornerRadius)
                                .overlay {
                                    Button(action: {
                                        selectedImages.remove(at: index)
                                    }) {
                                        Image.SRIconSet.xmarkCircleFill.frame(.defaultIconSize)
                                            .foregroundColor(.srGray)
                                            .background(Color.srWhite)
                                            .clipShape(Circle())
                                            .offset(x: Constants.deleteButtonOffset, y: -Constants.deleteButtonOffset)
                                    }
                                }
                        }

                        Button {
                            isShowingImagePicker = true
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
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
                }
            }
            .sheet(isPresented: $isShowingImagePicker) {
                MultiImagePicker(selectedImages: $selectedImages)
            }
        }
    }
}
