//
//  CollectionLikerSheet.swift
//  saerok
//
//  Created by HanSeung on 9/14/25.
//

import SwiftUI

extension CollectionLikerSheet {
    @Observable
    final class ViewModel {
        private(set) var likers: [Local.UserSummary] = []
        
        private let interactor: CollectionInteractor
        private let collectionID: Int
        
        init(collectionID: Int, interactor: CollectionInteractor) {
            self.likers = .init()
            self.interactor = interactor
            self.collectionID = collectionID
        }
        
        @MainActor
        func refresh() async {
            do {
                likers = try await interactor.fetchLikeUsers(collectionID)
            } catch {
                
            }
        }
    }
}

struct CollectionLikerSheet: View {
    typealias Route = CollectionDetailRoute
    
    @EnvironmentObject private var coordinator: AppCoordinator
    @State private var viewModel: ViewModel
    let onDismiss: () -> Void
    
    init(viewModel: ViewModel, onDismiss: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        content
            .task { await viewModel.refresh() }
    }
}

private extension CollectionLikerSheet {
    var content: some View {
        VStack(alignment: .center, spacing: 0) {
            header
            likerList
        }
        .srbottomSheetStyle(presentationDetent: [.fraction(0.7)])
    }
    
    var header: some View {
        ZStack(alignment: .top) {
            HStack {
                Text("좋아요")
                Text("\(viewModel.likers.count)")
                    .foregroundStyle(.splash)
                Spacer()
                Button(action: onDismiss) {
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
                ForEach(viewModel.likers) { item in
                    Button {
                        onDismiss()
                        coordinator.push(Route.other(item.id))
                    } label: {
                        CollectionLikerCell(item: item)
                    }
                    .buttonStyle(.plain)
                }
                
                Color.clear
                    .frame(height: UIScreen.main.bounds.height * 0.3)
            }
        }
        .refreshable { await viewModel.refresh() }
    }
}
