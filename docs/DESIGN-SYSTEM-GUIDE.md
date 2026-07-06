# 디자인 시스템 가이드 (SRDesignSystem)

디자인 시스템의 **구조·진입점·토큰 규칙**을 정의한다. 색상 팔레트·안티패턴 등 시각 언어는 [UI-GUIDE](UI-GUIDE.md) 참고.

## 레이어링 계약

```
saerok/Sources/Common/SRDesignSystem/
├── SRComponentStyle.swift   ← 유일한 스타일링 공개 진입점 (srStyled)
├── Foundation/              ← L0: 토큰 (폰트·아이콘·색·그림자·라디우스·간격·애니메이션)
├── Styles/                  ← L1: ViewModifier·ButtonStyle (상태 없는 외형 스타일)
├── Components/              ← L2: 자체 레이아웃을 가진 View (NavigationBar, Tabbar, SRTagBadge …)
├── Presentation/            ← L3: 오버레이·시트·토스트 modifier (sr* 접두사)
└── Catalog/                 ← DEBUG 전용 쇼케이스
```

의존 방향: **Foundation → Styles → Components/Presentation → Feature**. 상위 레이어만 하위를 참조한다.
Feature 코드가 스타일링 목적으로 알아야 하는 파일은 `SRComponentStyle.swift` 하나다.

## 진입점 규칙

| 스타일링 대상 | 진입점 | 규칙 |
|---|---|---|
| 디자인 값 | `SRShadow` / `SRRadius` / `SRSpacing` / `SRAnimation` / `Font.SRFontSet` / `Image.SRIconSet` / Color 에셋 | Feature 코드에서 hex·RGB·duration 리터럴 금지. 토큰에 없으면 토큰을 추가한다 |
| 기존 뷰의 외형 | **`.srStyled(_:)` 단일 진입점** | Styles/의 모든 스타일은 `SRComponentStyle` case로 등록한다. `.buttonStyle(.primary)` 등 static 접근은 디자인 시스템 내부 구현 디테일 |
| 자체 레이아웃 UI 조각 | Components/의 View struct 직접 인스턴스화 | `NavigationBar`, `TabbarView`, `SRTagBadge`, `SRCountLabel`, `SRDivider` 등. srStyled로 감싸지 않는다 |
| 오버레이·시트·토스트 (뷰 계층 변경) | Presentation/의 `sr*` modifier | `.srToast()` / `.srPopup()` / `.srBottomSheet()` (presentationDetents 래퍼) / `.srDynamicSheet()` (커스텀 드래그 시트) |

## 토큰 카탈로그

> **원칙: 값 보존, 미표준화.** 토큰 값은 앱에 실재하는 실측값이며 이번 재정비에서 표준화하지 않았다.
> 3회 이상 반복되는 조합만 프리셋으로 승격하고, 프리셋 이름에 값을 명시한다 (`card10` = opacity 0.1).
> 1회성 값은 호출부 인라인 유지 (`.black(0.07, radius: 6, y: 2)`).

| 토큰 | 값 | 용도 |
|------|-----|------|
| `SRShadow.card10` | black 0.1, r5 | 카드 그림자 최빈값 |
| `SRShadow.floating25` | black 0.25, r5 | 플로팅 원형 버튼 |
| `SRShadow.chipIcon10` | black 0.1, r5, y2 | 흰 원형 아이콘 칩 |
| `SRRadius.sheet` | 24 | 시트·대형 컨테이너 |
| `SRRadius.card` | 20 | 카드 (실사용 최빈값) |
| `SRRadius.item` | 10 | 소형 아이템·셀 |
| `SRSpacing.screenHorizontal` | 24 | 화면 좌우 기본 마진 |
| `SRSpacing.navBarSpacer` | 64 | 고정 NavigationBar 하단 스페이서 |
| `SRAnimation.easeInOut20/25/35` | 0.2/0.25/0.35s | 피드백·오버레이 전환 |
| `SRAnimation.spring35_90` | response 0.35, damping 0.9 | 플로팅 메뉴 |

색상 의미 매핑 표는 `Foundation/SRColor.swift` 참고.

## srStyled 스타일 목록

`textField` / `filterButton` / `defaultItem` / `primaryButton` / `secondaryButton` / `iconButton` / `borderedIconButton` / `alert(...)` /
`avatar(size:strokeColor:strokeWidth:strokeInset:)` / `card(radius:background:shadow:strokeColor:strokeWidth:strokeInset:)` /
`chip(background:horizontalPadding:verticalPadding:)` / `circleIconChip(fill:shadow:)` / `floatingButton(size:shadow:)`

사용 예:
```swift
// 카드 (그림자 실측값 전달, 기본값 = 최빈값)
content.srStyled(.card(shadow: .black(0.15, radius: 5)))
// 캡슐 칩 (배경 필수 — 호출부마다 분산이라 기본값 없음)
label.srStyled(.chip(background: .splash))
// 아바타 (기본 25pt / 스트로크 2)
image.srStyled(.avatar(strokeInset: 0.8))
```

## 새 스타일 추가 체크리스트

1. 같은 모디파이어 체인이 **2곳 이상** 반복되는지 확인한다. 1곳이면 추가하지 않는다.
2. `Styles/`에 `ViewModifier`(또는 `ButtonStyle`) 작성 — 반복 블록만 담고, 호출부마다 다른 패딩·프레임은 호출부에 남긴다.
3. `SRComponentStyle`에 case 추가 (기본값 = 현재 최빈값, 최빈값 없으면 필수 파라미터) + `apply(to:)` 분기.
4. 값이 새로 등장하면 Foundation 토큰 검토 (3회+ 반복 시에만 프리셋 승격).
5. `Catalog/DesignSystemCatalogView.swift`에 섹션 추가.
6. 치환 시 기존 모디파이어 **순서**까지 동일하게 보존한다. (`background → cornerRadius → overlay → shadow`)

## 알려진 부채 (이번 라운드 비목표)

- 시스템 폰트 우회 ~8파일 (`.font(.system(...))`, SRFontSet 위 `.fontWeight`) — 정확히 일치하는 토큰이 없어 보류
- 오타 색 에셋 `grdiendMid`, `pointtext` — rename 리스크로 보류
- 폰트 `_2/_3/_4` 접미사 체계 — 서체·웨이트 변형 의미만 문서화, 개편 보류
- 시맨틱 컬러 레이어(background/primary 등) — 문서 매핑만 존재
- BirdDetailView ChipList (비대칭 패딩 12/15), FloatingMenuModifier 서브 버튼(그림자 없는 62pt) — 패턴이 달라 의도적으로 미통합
