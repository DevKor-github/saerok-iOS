import SwiftUI

struct CommunityDetailView: View {
    let type: CommunityType
    
    @Environment(\.injected) var injected: DIContainer
    private var interactor: CommunityInteractor { injected.interactors.community }
    
    @State private var items: [Local.CommunityItemSummary] = []
    @State private var page: Int = 1
    private let size: Int = 20
    @State private var isLoading = false
    @State private var hasNext = true
    
    @Binding var path: NavigationPath

    var body: some View {
        content
            .task {
                await loadInitial()
            }
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            navigationBar
            itemList
        }
        .regainSwipeBack()
    }
    
    private var navigationBar: some View {
        NavigationBar(
            center: {
                barIcon
                HStack(spacing: 7) {
                    Text(type.title)
                        .font(.SRFontSet.subtitle2)
                }
            }, leading: {
                Button {
                    path.removeLast()
                } label: {
                    Image.SRIconSet.chevronLeft
                        .frame(.defaultIconSize)
                }
                .buttonStyle(.borderedIcon)
            })
    }
    
    @ViewBuilder
    private var barIcon: some View {
        switch type {
        case .recent:
            barIconStyle(icon: .commentCommunity, background: .accent)
        case .popular:
            barIconStyle(icon: .fire, background: .fire)
        case .suggestion:
            barIconStyle(icon: .unknown, background: .pointtext)
        case .search:
            EmptyView()
        }
    }
    
    private func barIconStyle(icon: Image.SRIconSet, background: Color) -> some View {
        icon
            .frame(.defaultIconSize, tintColor: icon == .unknown ? .srWhite : nil)
            .padding(4)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private var itemList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    Button {
                        path.append(CommunityView.Route.detail(id: item.id))
                    } label: {
                        CommunityCell(item: item, type: self.type)
                    }
                    .buttonStyle(.plain)
                    .onAppear {
                        if index == items.count - 1 {
                            Task { await loadMore() }
                        }
                    }
                }
                
                if isLoading {
                    ProgressView().padding()
                }
            }
        }
    }
}

// MARK: - Paging Methods

extension CommunityDetailView {
    private func loadInitial() async {
        page = 1
        hasNext = true
        items = []
        await loadMore()
    }

    private func loadMore() async {
        guard !isLoading, hasNext else { return }
        isLoading = true
        
        do {
            let newItems = try await interactor.fetchItems(
                type: type,
                page: page,
                size: size
            )
            
            items.append(contentsOf: newItems)
            if newItems.count < size {
                hasNext = false
            } else {
                page += 1
            }
        } catch {
            hasNext = false
        }
        
        isLoading = false
    }
}
