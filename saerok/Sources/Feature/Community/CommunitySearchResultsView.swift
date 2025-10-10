import SwiftUI

struct CommunitySearchResultsView: View {
    let text: String
    let searchMainItems: Local.CommunitySearchMainItems
    @Binding var path: NavigationPath
    @Binding var mode: SearchInputBar.Mode
    @Binding var searchCase: CommunitySearchCase
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    VStack(spacing: 8) {
                        Text("검색어를 입력해보세요")
                            .font(.SRFontSet.caption1)
                            .foregroundStyle(.srGray)
                            .padding(.top, 32)
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    switch searchCase {
                    case .all:
                        allResult
                    case .collection:
                        collectionResult
                    case .user:
                        userResult
                    }
                }

                Color.clear.frame(height: 90)
            }
        }
        .background(Color.srLightGray)
    }

    @ViewBuilder
    private var allResult: some View {
        Color.clear.frame(height: 0)

        if !searchMainItems.collections.isEmpty {
            VStack(spacing: 0) {
                sectionHeader(title: "새록", count: searchMainItems.collectionsCount)
                collectionResult
            }
        }

        if !searchMainItems.users.isEmpty {
            VStack(spacing: 0) {
                sectionHeader(title: "사용자", count: searchMainItems.usersCount)
                userResult
            }
        }
    }
    
    private var collectionResult: some View {
        VStack(spacing: 0) {
            ForEach(searchMainItems.collections) { item in
                Button {
                    path.append(CommunityView.Route.detail(id: item.id))
                } label: {
                    CommunityCell(item: item, type: .search(text))
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private var userResult: some View {
        VStack(spacing: 0) {
            ForEach(searchMainItems.users, id: \.id) { user in
                CommunityUserCell(item: user, keyword: text)
            }
        }
    }
    
    @ViewBuilder
    private func sectionHeader(title: String, count: Int) -> some View {
        HStack(spacing: 10) {
            Text(title)
                .font(.SRFontSet.subtitle1_3)
            Text("\(count)")
                .font(.SRFontSet.subtitle1_4)
                .foregroundStyle(.splash)
            Spacer()
            Button { } label: {
                HStack(spacing: 8) {
                    Text("더보기")
                        .font(.SRFontSet.caption1)
                        .foregroundStyle(.srDarkGray)
                    Image.SRIconSet.chevronRight
                        .frame(.defaultIconSizeSmall, tintColor: .srDarkGray)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 18)
        .background(Color.srWhite)
    }
}
