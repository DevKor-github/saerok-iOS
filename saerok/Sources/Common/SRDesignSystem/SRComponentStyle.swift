//
//  SRComponentStyle.swift
//  saerok
//
//  Created by HanSeung on 3/20/25.
//

import SwiftUI

/// SRComponentStyle
/// 공통 컴포넌트(View)에 적용할 스타일을 정의한 열거형입니다.
///
/// View 확장 메서드 `srStyled(_:)`를 통해 스타일을 손쉽게 적용할 수 있습니다.
///
/// 사용 예:
/// ```swift
/// TextField("제목", text: $title)
///     .srStyled(.textField(isFocused: $isFocused))
///
/// Button("필터") {}
///     .srStyled(.filterButton(isActive: isFiltered))
/// ```
enum SRComponentStyle {
    /// 텍스트 필드 스타일
    /// - Parameters:
    ///   - isFocused: 포커스 상태 바인딩. 포커스 여부에 따라 테두리/틴트 등의 상태가 바뀝니다.
    ///   - alwaysFocused: true일 경우 포커스가 없어도 포커스된 상태의 스타일을 유지합니다. (기본값: false)
    ///   - tintColor: 커서/포커스 포인트 등에 사용할 틴트 컬러. nil이면 기본 메인 컬러를 사용합니다.
    case textField(isFocused: FocusState<Bool>.Binding, alwaysFocused: Bool = false, tintColor: Color? = nil)
    /// 필터 버튼 스타일
    /// - Parameters:
    ///   - isActive: 필터가 활성화되었는지 여부. 활성화 상태에 따라 강조 스타일이 적용됩니다.
    ///   - isResetButton: 리셋(초기화) 버튼 여부. true면 별도의 보조 스타일이 적용됩니다. (기본값: false)
    case filterButton(isActive: Bool, isResetButton: Bool = false)
    /// 리스트/셀 등 기본 아이템에 적용하는 디폴트 스타일
    case defaultItem
    /// 기본 주요 액션(Primary)에 사용하는 버튼 스타일
    case primaryButton
    /// 아이콘 전용 버튼 스타일 (배경/크기/터치 영역 최적화)
    case iconButton
    /// 테두리가 있는 아이콘 버튼 스타일
    case borderedIconButton
    /// 아바타(프로필 이미지/이니셜) 스타일
    case avatar
    /// 경고(Alert) 컨텍스트에서 사용하는 버튼 스타일 집합
    /// - Parameter type: 확인/삭제/보더 등 세부 알럿 버튼 스타일 타입
    case alert(_ type: SRAlertStyle)

    /// 지정한 View에 스타일을 적용합니다.
    /// - Parameter view: 스타일을 적용할 대상 View
    /// - Returns: 스타일이 적용된 View
    @MainActor @ViewBuilder
    func apply(to view: some View) -> some View {
        switch self {
        case .textField(let isFocused, let alwaysFocused, let tintColor):
            view.modifier(SRTextFieldStyle(isFocused: isFocused, alwaysFocused: alwaysFocused, tintColor: tintColor ?? .main))
        case .filterButton(let isActive, let isResetButton):
            view.buttonStyle(FilterButtonStyle(isActive: isActive, isResetButton: isResetButton))
        case .defaultItem:
            view.modifier(DefaultItemStyle())
        case .iconButton:
            view.buttonStyle(.icon)
        case .borderedIconButton:
            view.buttonStyle(.borderedIcon)
        case .avatar:
            view.srAvatarStyle()
        case .primaryButton:
            view.buttonStyle(.primary)
        case .alert(.confirm):
            view.buttonStyle(.alert_confirm)
        case .alert(.delete):
            view.buttonStyle(.alert_delete)
        case .alert(.bordered):
            view.buttonStyle(.alert_bordered)
        }
    }
}

extension View {
    /// View에 `SRComponentStyle`을 간결하게 적용하는 헬퍼 메서드
    /// - Parameter style: 적용할 컴포넌트 스타일
    /// - Returns: 스타일이 적용된 View
    func srStyled(_ style: SRComponentStyle) -> some View {
        style.apply(to: self)
    }
}

