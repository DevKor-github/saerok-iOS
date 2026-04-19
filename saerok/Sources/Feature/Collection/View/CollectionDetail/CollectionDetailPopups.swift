import SwiftUI

// MARK: - Popup Layer View

extension CollectionDetailView {
    struct CollectionPopupLayer: View {
        @Binding var showPopup: Bool
        @Binding var showSuggestPopup: Bool
        @Binding var showAdoptPopup: Bool
        @Binding var showBlockPopup: Bool

        let alertConfig: PopupConfig?
        let adoptConfig: PopupConfig?
        let suggestConfig: PopupConfig?
        let blockUserConfig: PopupConfig?

        var body: some View {
            EmptyView()
                .srPopup(isPresented: $showPopup, config: alertConfig)
                .srPopup(isPresented: $showSuggestPopup, config: suggestConfig)
                .srPopup(isPresented: $showAdoptPopup, config: adoptConfig)
                .srPopup(isPresented: $showBlockPopup, config: blockUserConfig)
        }
    }

    struct InvalidAlertView: View {
        let action: () -> Void

        private var popupConfig: PopupConfig {
            PopupConfig(
                title: "존재하지 않는 새록이에요",
                message: "새록이 삭제되었거나\n데이터를 불러올 수 없어요.",
                buttons: .single(.init(title: "확인", style: .confirm, action: action))
            )
        }

        var body: some View {
            ZStack {
                Color.black.opacity(0.4)
                    .transition(.opacity)
                    .zIndex(1)
                SRPopup(
                    title: popupConfig.title,
                    message: popupConfig.message,
                    buttons: popupConfig.buttons
                )
                .zIndex(10)
                .transition(.scale)
            }
        }
    }
}
