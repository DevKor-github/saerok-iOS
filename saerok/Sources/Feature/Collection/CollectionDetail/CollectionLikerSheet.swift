//
//  CollectionLikerSheet.swift
//  saerok
//
//  Created by HanSeung on 9/14/25.
//


import SwiftUI

struct CollectionLikerSheet: View {
    @Environment(\.injected) private var injected: DIContainer
    
    let collectionID: Int
    let onDismiss: () -> Void
    @State private var likers: [Local.UserSummary] = []
    @State private var isLoading: Bool = true
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            ZStack(alignment: .top) {
                HStack {
                    Text("좋아요")
                    Text("\(likers.count)")
                        .foregroundStyle(.splash)
                    Spacer()
                    Button(action: { onDismiss() }) {
                        Image.SRIconSet.delete
                            .frame(.defaultIconSizeSmall, tintColor: .srGray)
                            .padding(.leading, 20)
                            .padding(.vertical, 5)
                    }
                    .contentShape(Rectangle())
                }
                .font(.SRFontSet.subtitle2)
                .padding(.horizontal, SRDesignConstant.defaultPadding)
                .padding(.vertical, 22)
                .background(.srLightGray)
                sheetIndicator
            }
            
            ScrollView {
                VStack(spacing: 7) {
                    ForEach(likers) { item in
                        CollectionLikeCell(item: item)
                    }
                    Color.clear
                        .frame(height: UIScreen.main.bounds.height * 0.5)
                }
            }
        }
        .presentationDetents([.fraction(0.7)])
        .presentationCornerRadius(30)
        .presentationBackground(.srLightGray)
        .presentationDragIndicator(.hidden)
        .ignoresSafeArea(edges: .bottom)
        .shimmer(when: $isLoading)
        .onAppear {
            Task {
                likers = try await injected.interactors.collection.fetchLikeUsers(collectionID)
                isLoading = false
            }
        }
    }
}
