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
    var addModeExitConfirmPopup: CustomPopup<BorderedButtonStyle, ConfirmButtonStyle, PrimaryButtonStyle> {
        CustomPopup(
            title: "작성 중인 내용이 있어요",
            message: "이대로 나가면 변경사항이 저장되지 않아요.\n취소할까요?",
            leading: .init(
                title: "나가기",
                action: {
                    activePopup = .addModeExitConfirm
                    path.removeLast()
                },
                style: .bordered
            ),
            trailing: .init(
                title: "계속하기",
                action: {
                    activePopup = .none
                },
                style: .confirm
            ),
            center: nil
        )
    }
    
    var editModeSaveConfirmPopup: CustomPopup<BorderedButtonStyle, ConfirmButtonStyle, PrimaryButtonStyle> {
        CustomPopup(
            title: "내용을 저장할까요?",
            message: "이대로 나가면 변경사항이 저장되지 않아요.\n취소할까요?",
            leading: .init(
                title: "저장 안할래요",
                action: {
                    activePopup = .none
                    path.removeLast()
                },
                style: .bordered
            ),
            trailing: .init(
                title: "저장할게요",
                action: {
                    activePopup = .none
                    editCollection()
                },
                style: .confirm
            ),
            center: nil
        )
    }
    
    var editModeDeleteConfirmPopup: CustomPopup<DeleteButtonStyle, ConfirmButtonStyle, PrimaryButtonStyle> {
        CustomPopup(
            title: "삭제하시겠어요?",
            message: "'\(self.collectionDraft.bird?.name ?? "이름 모를 새")' 새록이 삭제돼요.",
            leading: .init(
                title: "삭제하기",
                action: {
                    activePopup = .editModeDeleteConfirm
                    deleteCollection()
                },
                style: .delete
            ),
            trailing: .init(
                title: "취소",
                action: {
                    activePopup = .none
                },
                style: .confirm
            ),
            center: nil
        )
    }
}
