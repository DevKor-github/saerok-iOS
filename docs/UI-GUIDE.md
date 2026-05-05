# UI 디자인 가이드

## 디자인 원칙
1. **기록 도구처럼 보여야 한다.** 마케팅 앱이 아니라 매일 쓰는 도감 앱이다. 장식보다 정보 밀도가 우선이다.
2. **밝고 가벼운 화면.** 배경은 흰색 계열(`.srWhite`, `.srLightGray`)이 기본이다. 어둡고 글로우가 뜨는 다크 테마는 이 앱의 언어가 아니다.
3. **브랜드 색상은 한 번만 써야 눈에 띈다.** `.main(#91BFFF)`은 CTA, 활성 상태, 핵심 강조에만 쓴다. 남발하면 어디도 강조되지 않는다.

## AI 슬롭 안티패턴 — 하지 마라
| 금지 사항 | 이유 |
|-----------|------|
| `blur`/`ultraThinMaterial` 남용 | glass morphism은 AI 템플릿의 가장 흔한 징후. 탭바 배경 등 꼭 필요한 곳 외에는 쓰지 않는다 |
| 그라데이션 텍스트 | 이 앱의 텍스트 색상은 단색이다. 그라데이션 텍스트를 쓰면 앱 언어에서 벗어난다 |
| 네온/글로우 Shadow | `shadow(color: .main, radius: 20)` 류의 글로우 효과는 사용하지 않는다 |
| 보라/인디고 계열 색상 추가 | 브랜드 컬러는 이미 정해져 있다. 임의로 새로운 색상을 추가하지 않는다 |
| 모든 컨테이너에 동일한 큰 radius | radius 값은 용도마다 다르다 (대: 24, 카드: 10, 버튼: 20). 무조건 큰 값을 쓰지 않는다 |
| 배경 장식 도형/그라데이션 orb | 내용 없는 배경 장식은 쓰지 않는다 |
| 과도한 애니메이션 | 스프링 기반의 짧은 피드백만 허용한다. 화면 전체가 움직이는 애니메이션은 금지 |

---

## 색상
색상은 반드시 Asset Catalog의 이름으로 참조한다. 하드코딩 hex 값은 쓰지 않는다.

### 배경
| 용도 | 에셋 이름 | 근사 Hex |
|------|-----------|---------|
| 페이지 배경 | `SRWhite` | `#FEFEFE` |
| 보조 배경, 바텀시트 | `SRLightGray` | `#F2F2F2` |
| 텍스트 필드 배경 | `SRWhite` | `#FEFEFE` |

### 텍스트
| 용도 | 에셋/색상 | 근사 Hex |
|------|-----------|---------|
| 주 텍스트 | `.primary` (시스템) | — |
| 보조 텍스트 | `SRGray` | `#969696` |
| 비활성/플레이스홀더 | `BorderColor` | `#D9D9D9` |

### 브랜드/시맨틱 색상
| 용도 | 에셋 이름 | 근사 Hex |
|------|-----------|---------|
| 핵심 브랜드, CTA, 활성 상태 | `MainColor` | `#91BFFF` |
| 브랜드 연하게 | `MainLightColor` | `#CDD9F3` |
| 포인트/강조 | `Point` | `#F9E2BE` |
| 포인트 연하게 | `PointLight` | `#F1E9DD` |
| 성공/긍정 | `srGreen` | `#51BBA6` |
| 에러/경고/삭제 | `fire` | `#F77A65` |
| 성공 토스트 | `splash` | `#4190FF` |
| 아이콘 반투명 배경 | `GlassWhite` | `#FEFEFE @ 60%` |
| 탭바/토글 비활성 배경 | `whiteGray` | — |

> **참고**: 코드에서는 Color extension을 통해 `.main`, `.srWhite`, `.srGray`, `.border`, `.srLightGray`, `.srGreen`, `.fire`, `.splash`, `.glassWhite`, `.whiteGray`, `.point`, `.pointLight` 등의 단축 프로퍼티로 접근한다.

---

## 타이포그래피
폰트는 반드시 `SRFontSet` enum을 통해 적용한다 (`.font(.SRFontSet.body1)`). 시스템 폰트를 직접 쓰지 않는다.

### 폰트 패밀리
- **Pretendard** — 기본 UI 폰트. 가독성 최우선.
- **잘풀리는하루(Jalpullineunharu)** — 디스플레이/헤드라인 전용. 앱의 감성을 담는다.
- **Moneygraphy** — 악센트/포인트 전용. 서브타이틀이나 캡션에 제한적으로 사용한다.

### 주요 스타일 대응표
| 용도 | SRFontSet 키 | 폰트 | 크기 | 굵기 |
|------|-------------|------|------|------|
| 페이지 타이틀 | `headline1` | 자필리는하루 | 30 | Regular |
| 섹션 타이틀 | `headline2` | 자필리는하루 | 22 | Regular |
| 섹션 타이틀 (강조) | `headline2_3` | Pretendard | 22 | SemiBold |
| 카드 타이틀 | `subtitle1` | Moneygraphy | 20 | Regular |
| 서브타이틀 | `subtitle2` | 자필리는하루 | 18 | Regular |
| 본문 | `body1` | Pretendard | 15 | Regular |
| 본문 (SemiBold) | `body2_3` | Pretendard | 15 | SemiBold |
| 작은 본문 | `body4` | Pretendard | 14 | Regular |
| 캡션 | `caption1` | Pretendard | 13 | Regular |
| 작은 캡션 | `caption3` | Pretendard | 12 | Regular |
| Primary 버튼 텍스트 | `button1` | Pretendard | 18 | Bold |
| Secondary 버튼 텍스트 | `button2` | Pretendard | 15 | SemiBold |
| 탭바 비활성 | `tabbar` | Pretendard | 11 | Regular |
| 탭바 활성 | `tabbarSelected` | Pretendard | 11 | Medium/Bold |
| 대형 수치 표시 | `heavy` | Pretendard | 40 | SemiBold |

---

## 컴포넌트
### 버튼

**Primary 버튼** (`PrimaryButtonStyle`)
- 배경: `.main` / 비활성: `.border`
- 텍스트: `.srWhite`, `SRFontSet.button1`
- Corner Radius: 20
- Vertical Padding: 16
- Width: `maxWidth: .infinity`
- Press: scale 0.98 + 햅틱 (Light)

```swift
Button("확인") { }
    .buttonStyle(PrimaryButtonStyle())
```

**Secondary/Alert 버튼** (`SecondaryButtonStyle`, `AlertButtonStyle`)
- 배경: 투명 또는 흰색, 테두리 강조
- 텍스트: `.primary` 또는 `.main`
- Corner Radius: 10 (secondary), 15 (alert)
- Vertical Padding: 11
- Press: scale 0.98

**Filter 버튼** (`FilterButtonStyle`)
- 활성: `.main` 배경 + `.srWhite` 텍스트
- 비활성: `.srWhite` 배경 + `.primary` 텍스트 + `.srGray` 0.35pt 테두리
- Corner Radius: Infinity (pill)
- Padding: 15H × 9V

**아이콘 버튼** (`SRIconButtonStyle`, `BorderedIconButtonStyle`)
- 배경 원: `.glassWhite` 40×40
- Bordered 변형: `.srLightGray` 1pt 테두리
- Press: scale 0.98

---

### 텍스트 필드 (`SRTextFieldStyle`)
- 배경: `.srWhite`
- Border Radius: 17
- Border: 2pt — 비포커스 `.border`, 포커스 `.main`
- 폰트: `SRFontSet.body2`
- 자동수정: 비활성화
- 변형: `alwaysFocused` (항상 `.main` 테두리 유지)

---

### 카드/아이템
| 컴포넌트 | 배경 | Corner Radius | Shadow |
|----------|------|---------------|--------|
| 일반 카드 | `.srWhite` | 20 | black 0.2, blur 5 |
| 내부 뱃지/태그 | `.main` | 10 | 없음 |
| 팝업 | `.srWhite` | 20 | dim overlay black 0.4 |

---

### 탭바 (`TabbarView`)
- 높이: 78
- 배경: White
- Corner Radius: Infinity
- Shadow: black 0.15, blur 15
- 수평 패딩: 16

---

### 내비게이션 바 (`NavigationBar`)
- 높이: 62
- 배경: `.srWhite` (변경 가능)
- 수평 패딩: 24
- 레이아웃: 양쪽 끝 Leading/Trailing + 중앙 타이틀

---

### 바텀시트 (`SRBottomSheetModifier`)
- 배경: `.srLightGray` (기본, 변경 가능)
- Drag Indicator: 숨김 → 커스텀 Indicator 사용 (Capsule 110×3, `.whiteGray`, 상단 5pt 패딩)
- Bottom Safe Area: 무시

---

### 토스트 (`SRToastModifier`)
- 배경: White 0.8 opacity
- Corner Radius: 12
- Border: 1pt (타입별 색상 — success: green, failure: red, normal: gray)
- 폰트: `SRFontSet.body2`
- 아이콘 영역: 25×25, corner 8
- 패딩: leading 6, trailing 13, vertical 5
- 닫기 제스처: 30pt 아래 스와이프

---

### 팝업 (`SRPopup`)
- 배경: `.srWhite`, Corner Radius 20
- 최대 너비: 300
- Overlay: black 0.4
- 타이틀 폰트: `SRFontSet.body3` (Moneygraphy 15)
- 본문 폰트: `SRFontSet.body2` (Pretendard 15)
- 트랜지션: scale insert + opacity remove

---

### 토글 (`ToggleButton`)
- 프레임: 55×30, Corner Radius Infinity
- OFF: `.whiteGray` 배경
- ON: `.main` 배경
- 핸들: `.srWhite` 원 25×25, 패딩 2.5pt

---

### 아바타 (`SRAvatarStyle`)
- 프레임: 25×25, Circle
- 테두리: `.srLightGray` 2pt stroke, inset 0.6pt

---

## 아이콘
- **SF Symbols**: `chevronLeft`, `chevronRight`, `xmark`, `xmarkCircleFill`, `pencil.fill`, `textformat`
- **커스텀 PNG**: `SRIconSet` enum을 통해 에셋 이름으로 참조
- 렌더링: `.renderingMode(.template)` 후 `.foregroundColor()` 적용
- 크기 상수 (`SRIconSet.Metric`):
  | 이름 | 크기 |
  |------|------|
  | `defaultIconSizeSmall` | 13×13 |
  | `defaultIconSize` | 17×17 |
  | `defaultIconSizeLarge` | 24×24 |
  | `defaultIconSizeVeryLarge` | 40×40 |
  | `floatingButton` | 61×61 |
- **아이콘을 둥근 배경 박스로 감싸지 않는다.** 단독 또는 `.glassWhite` 원형 배경(`SRIconButtonStyle`) 중 하나만 선택.

---

## 레이아웃
- 기본 수평 패딩: `SRDesignConstant.defaultPadding` = **24pt**
- 카드 Corner Radius: `SRDesignConstant.cardCornerRadius` = **10pt**
- 대형 Corner Radius: `SRDesignConstant.cornerRadius` = **24pt**
- 요소 간격: 4–8pt (tight), 12–16pt (standard), 24pt+ (섹션 간)
- 좌측 정렬 기본. 리스트/그리드는 `AdaptiveLeftAlignedGrid` 활용.

---

## 애니메이션
허용하는 애니메이션만 나열한다. 그 외는 사용하지 않는다.

| 종류 | 스펙 | 사용처 |
|------|------|--------|
| 버튼 press scale | `scaleEffect(0.98)`, `Animation(.spring(duration: 0.2))` | 모든 탭 가능 요소 |
| 팝업 등장 | `.scale` insert + `.opacity` remove, spring 0.2s | SRPopup |
| 모달 등장 | interpolating spring (duration 0.35, bounce 0) | 바텀시트, 풀스크린 |
| 탭 전환 | 없음 (즉각 전환) | TabbarView |

- 화면 전체 shake, 반복 pulse, 글로우 애니메이션은 **금지**.
- 햅틱 피드백: 탭/선택 시 `HapticManager.shared.trigger(.light)`

---

## 확장 패턴 (View Extension)
새 UI를 만들 때 아래 modifier 패턴을 먼저 확인하고 재사용한다.

| Extension | 역할 |
|-----------|------|
| `.srStyled(style:)` | SRComponentStyle 기반 통합 스타일 적용 |
| `.srBottomSheet(isPresented:)` | SRBottomSheetModifier 적용 |
| `.srPopup(isPresented:popup:)` | SRPopup 오버레이 표시 |
| `.srToast(data:)` | SRToastModifier 토스트 표시 |
| `.srAvatarStyle()` | SRAvatarStyle 적용 |

---

## 설계 상수 참조
```swift
enum SRDesignConstant {
    static let cornerRadius: CGFloat = 24.0       // 대형 컨테이너
    static let cardCornerRadius: CGFloat = 10.0   // 카드, 뱃지
    static let defaultPadding: CGFloat = 24.0     // 기본 수평 패딩
}
```
