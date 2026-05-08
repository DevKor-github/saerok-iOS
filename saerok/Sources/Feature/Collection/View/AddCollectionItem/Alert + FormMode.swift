//
//  Alert + FormMode.swift
//  saerok
//
//  Created by HanSeung on 6/9/25.
//


enum CollectionPopup {
    case none
    case addModeExitConfirm
    case editModeSaveConfirm
    case editModeDeleteConfirm
}

enum CollectionFormMode {
    case add
    case edit(_ detail: Local.CollectionDetail)
    
    var title: String {
        switch self {
        case .add: return "새록 작성하기"
        case .edit: return "새록 수정하기"
        }
    }
    
    var submitButtonTitle: String {
        switch self {
        case .add: return "종 추가"
        case .edit: return "편집 완료"
        }
    }
    
    var showDeleteButton: Bool {
        switch self {
        case .add: return true
        case .edit: return true
        }
    }
    
    var isAddMode: Bool {
        if case .add = self { return true }
        return false
    }
}

extension CollectionFormView {
    var currentPopupConfig: PopupConfig? {
        switch viewModel.activePopup {
        case .addModeExitConfirm:
            addModeExitConfirmPopupConfig
        case .editModeSaveConfirm:
            editModeSaveConfirmPopup
        case .editModeDeleteConfirm:
            editModeDeleteConfirmPopup
        case .none:
            nil
        }
    }

    var addModeExitConfirmPopupConfig: PopupConfig {
        .init(
            title: "작성 중인 내용이 있어요",
            message: "이대로 나가면 변경사항이 저장되지 않아요.\n취소할까요?",
            buttons: .double(
                .init(
                    title: "계속하기",
                    style: .confirm,
                    action: { viewModel.dismissPopup() }
                ),
                .init(
                    title: "나가기",
                    style: .bordered,
                    action: {
                        viewModel.dismissPopup()
                        coordinator.pop()
                    }
                )
            )
        )
    }

    var editModeSaveConfirmPopup: PopupConfig {
        PopupConfig(
            title: "이전 동정 돕기 내역을 불러올까요?",
            message: "불러오지 않으면 동정 돕기가 처음부터 시작돼요.",
            buttons: .double(
                .init(
                    title: "불러오지 않기",
                    style: .bordered,
                    action: {
                        viewModel.dismissPopup()
                        Task { await viewModel.performEdit(resetSuggestion: true) }
                    }
                ),
                .init(
                    title: "불러오기",
                    style: .confirm,
                    action: {
                        viewModel.dismissPopup()
                        Task { await viewModel.performEdit() }
                    }
                )
            )
        )
    }

    var editModeDeleteConfirmPopup: PopupConfig {
        PopupConfig(
            title: "삭제하시겠어요?",
            message: "'\(viewModel.collectionDraft.bird?.name ?? "이름 모를 새")' 새록이 삭제돼요.",
            buttons: .double(
                .init(
                    title: "취소",
                    style: .confirm,
                    action: { viewModel.dismissPopup() }
                ),
                .init(
                    title: "삭제하기",
                    style: .delete,
                    action: {
                        viewModel.dismissPopup()
                        deleteCollection()
                    }
                )
            )
        )
    }
}
