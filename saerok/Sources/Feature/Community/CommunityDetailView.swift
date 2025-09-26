import SwiftUI

struct CommunityDetailView: View {
    let type: CommunityType
    
    @Environment(\.injected) var injected: DIContainer
    private var interactor: CommunityInteractor { injected.interactors.community }
    
    @State private var items: [Local.CommunityItemSummary] = []
    @Binding var path: NavigationPath

    var body: some View {
        content
            .task {
                do {
                    items = try await interactor.fetchItems(type: type, page: nil, size: nil)
                } catch { }
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
                Text(type.title)
                    .font(.SRFontSet.subtitle2)
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
    
    private var itemList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(items) { item in
                    Button {
                        path.append(CommunityView.Route.detail(id: item.id))
                    } label: {
                        CommunityCell(item: item, type: type)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        CommunityDetailView(type: .popular, path: .constant(.init()))
    }
}
