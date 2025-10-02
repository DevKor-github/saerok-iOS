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
    
    private var barIcon: some View {
        switch type {
        case .recent:
            barIconStyle(icon: .commentCommunity, background: .accent)
        case .popular:
            barIconStyle(icon: .fire, background: .fire)
        case .suggestion:
            barIconStyle(icon: .unknown, background: .pointtext)

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
                ForEach(items) { item in
                    Button {
                        path.append(CommunityView.Route.detail(id: item.id))
                    } label: {
                        CommunityCell(item: item)
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
