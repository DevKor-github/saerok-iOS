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
    
    @Binding var path: NavigationPath
    
    var body: some View {
        content
            .task {
                await reloadData()
            }
    }
}

// MARK: - Subviews


private extension CollectionLikerSheet {
    var content: some View {
        VStack(alignment: .center, spacing: 0) {
            header
            likerList
        }
        .srbottomSheetStyle(presentationDetent: [.fraction(0.7)])
        .shimmer(when: $isLoading)
    }
    
    var header: some View {
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
    }
    
    var likerList: some View {
        ScrollView {
            VStack(spacing: 7) {
                ForEach(likers) { item in
                    Button {
                        onDismiss()
                        path.append(CollectionDetailView.Route.other(item.id))
                    } label: {
                        CollectionLikerCell(item: item)
                    }
                    .buttonStyle(.plain)
                }
                
                Color.clear
                    .frame(height: UIScreen.main.bounds.height * 0.3)
            }
        }
        .refreshable {
            await reloadData()
        }
    }
}

// MARK: - Helpers

private extension CollectionLikerSheet {
    func reloadData() async {
        do {
            likers = try await injected.interactors.collection.fetchLikeUsers(collectionID)
            isLoading = false
        } catch {
            isLoading = false
        }
    }
}
