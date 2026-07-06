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
    /// 보조 액션(Secondary) 버튼 스타일 (투명 배경, 텍스트 중심)
    case secondaryButton
    /// 아이콘 전용 버튼 스타일 (배경/크기/터치 영역 최적화)
    case iconButton
    /// 테두리가 있는 아이콘 버튼 스타일
    case borderedIconButton
    /// 아바타(프로필 이미지) 스타일 — 크기·스트로크는 호출부 실측값을 그대로 전달
    /// - Parameters:
    ///   - size: 아바타 한 변 크기 (기본 25)
    ///   - strokeColor: 테두리 색 (기본 .srLightGray)
    ///   - strokeWidth: 테두리 두께 (기본 2). 0이면 테두리 생략
    ///   - strokeInset: 테두리 inset (기본 0.6)
    case avatar(size: CGFloat = 25, strokeColor: Color = .srLightGray, strokeWidth: CGFloat = 2, strokeInset: CGFloat = 0.6)
    /// 카드 스타일: 배경 + 코너 + (옵션) 테두리 + (옵션) 그림자. 값 표준화 없음 — 실측값을 파라미터로 전달
    /// - Parameters:
    ///   - radius: 코너 라디우스 (기본 SRRadius.card = 20)
    ///   - background: 배경색 (기본 .srWhite)
    ///   - shadow: 그림자 토큰. nil이면 그림자 없음 (기본 .card10)
    ///   - strokeColor: 테두리 색. nil이면 테두리 없음 (기본 nil)
    ///   - strokeWidth: 테두리 두께 (기본 1)
    ///   - strokeInset: 테두리 inset (기본 0)
    case card(radius: CGFloat = SRRadius.card, background: Color = .srWhite, shadow: SRShadow? = .card10, strokeColor: Color? = nil, strokeWidth: CGFloat = 1, strokeInset: CGFloat = 0)
    /// 캡슐 칩: 패딩 + 배경 + 무한 코너. 전경색은 호출부 스타일 보존을 위해 미포함
    /// - Parameters:
    ///   - background: 배경색 (필수 — 호출부마다 분산되어 기본값 없음)
    ///   - horizontalPadding: 좌우 패딩 (기본 15)
    ///   - verticalPadding: 상하 패딩 (기본 9)
    case chip(background: Color, horizontalPadding: CGFloat = 15, verticalPadding: CGFloat = 9)
    /// 원형 아이콘 칩: 아이콘 뒤 흰 원 + 그림자 배경
    case circleIconChip(fill: Color = .white, shadow: SRShadow? = .chipIcon10)
    /// 플로팅 원형 버튼 이미지 스타일: Button label 안의 Image에 적용 (`.resizable()`은 호출부 유지)
    case floatingButton(size: CGFloat = 61, shadow: SRShadow = .floating25)
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
        case .avatar(let size, let strokeColor, let strokeWidth, let strokeInset):
            view.modifier(SRAvatarStyle(size: size, strokeColor: strokeColor, strokeWidth: strokeWidth, strokeInset: strokeInset))
        case .card(let radius, let background, let shadow, let strokeColor, let strokeWidth, let strokeInset):
            view.modifier(SRCardStyle(radius: radius, background: background, shadow: shadow, strokeColor: strokeColor, strokeWidth: strokeWidth, strokeInset: strokeInset))
        case .chip(let background, let horizontalPadding, let verticalPadding):
            view.modifier(SRChipStyle(background: background, horizontalPadding: horizontalPadding, verticalPadding: verticalPadding))
        case .circleIconChip(let fill, let shadow):
            view.modifier(SRCircleIconChipStyle(fill: fill, shadow: shadow))
        case .floatingButton(let size, let shadow):
            view.modifier(SRFloatingButtonStyle(size: size, shadow: shadow))
        case .primaryButton:
            view.buttonStyle(.primary)
        case .secondaryButton:
            view.buttonStyle(.secondary)
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

