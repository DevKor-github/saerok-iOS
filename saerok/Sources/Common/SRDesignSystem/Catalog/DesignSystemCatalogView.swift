//
//  DesignSystemCatalogView.swift
//  saerok
//
//  Created by HanSeung on 7/6/26.
//

#if DEBUG
import SwiftUI

/// 디자인 시스템 쇼케이스 — Xcode Preview 전용 (내비게이션 미등록, 릴리즈 바이너리 미포함).
///
/// 새 토큰·스타일을 추가하면 이 카탈로그에도 섹션을 추가한다. ([DESIGN-SYSTEM-GUIDE](../../../../docs/DESIGN-SYSTEM-GUIDE.md) 체크리스트 5번)
struct DesignSystemCatalogView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                colorSection
                typographySection
                shadowSection
                radiusSection
                buttonSection
                cardSection
                chipSection
                avatarSection
                componentSection
            }
            .padding(SRSpacing.screenHorizontal)
        }
        .background(Color.srLightGray)
    }
}

private extension DesignSystemCatalogView {
    func section(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.SRFontSet.subtitle1_3)
            content()
        }
    }

    var colorSection: some View {
        section("Colors") {
            let colors: [(String, Color)] = [
                ("main", .main), ("splash", .splash), ("srWhite", .srWhite),
                ("srGray", .srGray), ("srLightGray", .srLightGray), ("srDarkGray", .srDarkGray),
                ("whiteGray", .whiteGray), ("glassWhite", .glassWhite), ("border", .border),
                ("fire", .fire), ("pointtext", .pointtext), ("srGreen", .srGreen),
                ("srDivider92", .srDivider92), ("srInputBorder", .srInputBorder), ("srGray59", .srGray59)
            ]
            LazyVGrid(columns: [.init(.adaptive(minimum: 90))], spacing: 8) {
                ForEach(colors, id: \.0) { name, color in
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: SRRadius.item)
                            .fill(color)
                            .frame(height: 44)
                            .overlay(RoundedRectangle(cornerRadius: SRRadius.item).stroke(.border, lineWidth: 0.5))
                        Text(name).font(.SRFontSet.caption3)
                    }
                }
            }
        }
    }

    var typographySection: some View {
        section("Typography") {
            let fonts: [(String, Font)] = [
                ("headline1", .SRFontSet.headline1), ("headline2", .SRFontSet.headline2),
                ("subtitle1", .SRFontSet.subtitle1), ("subtitle2", .SRFontSet.subtitle2),
                ("body0", .SRFontSet.body0), ("body1 (=body2·2_2·4_2)", .SRFontSet.body1),
                ("body2_3", .SRFontSet.body2_3), ("body3", .SRFontSet.body3),
                ("caption0", .SRFontSet.caption0), ("caption1 (=caption1_2)", .SRFontSet.caption1),
                ("caption3", .SRFontSet.caption3), ("button (=button1)", .SRFontSet.button)
            ]
            VStack(alignment: .leading, spacing: 6) {
                ForEach(fonts, id: \.0) { name, font in
                    Text("새록 Saerok 123 — \(name)").font(font)
                }
            }
        }
    }

    var shadowSection: some View {
        section("Shadows") {
            HStack(spacing: 20) {
                shadowSample("card10", .card10)
                shadowSample("floating25", .floating25)
                shadowSample("chipIcon10", .chipIcon10)
            }
            .padding(.vertical, 8)
        }
    }

    func shadowSample(_ name: String, _ shadow: SRShadow) -> some View {
        VStack(spacing: 6) {
            RoundedRectangle(cornerRadius: SRRadius.card)
                .fill(Color.srWhite)
                .frame(width: 80, height: 60)
                .srShadow(shadow)
            Text(name).font(.SRFontSet.caption3)
        }
    }

    var radiusSection: some View {
        section("Radii") {
            HStack(spacing: 20) {
                ForEach([("sheet 24", SRRadius.sheet), ("card 20", SRRadius.card), ("item 10", SRRadius.item)], id: \.0) { name, r in
                    VStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: r)
                            .fill(Color.srWhite)
                            .frame(width: 80, height: 60)
                        Text(name).font(.SRFontSet.caption3)
                    }
                }
            }
        }
    }

    var buttonSection: some View {
        section("Buttons") {
            VStack(spacing: 10) {
                Button("primaryButton") {}.srStyled(.primaryButton)
                Button("secondaryButton") {}.srStyled(.secondaryButton)
                HStack {
                    Button { } label: { Image.SRIconSet.chevronLeft.frame(.default) }
                        .srStyled(.iconButton)
                    Button { } label: { Image.SRIconSet.xmark.frame(.default) }
                        .srStyled(.borderedIconButton)
                    Button("filter") {}.srStyled(.filterButton(isActive: true))
                    Button("filter") {}.srStyled(.filterButton(isActive: false))
                }
            }
        }
    }

    var cardSection: some View {
        section("Cards — srStyled(.card)") {
            VStack(spacing: 14) {
                Text("기본 (shadow: .card10)")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .srStyled(.card())
                Text("그림자 없음 + 스트로크")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .srStyled(.card(shadow: nil, strokeColor: .splash, strokeInset: 0.5))
                Text("실측 그림자 전달 (0.07, r6, y2)")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .srStyled(.card(shadow: .black(0.07, radius: 6, y: 2), strokeColor: .whiteGray, strokeInset: 0.5))
            }
        }
    }

    var chipSection: some View {
        section("Chips — srStyled(.chip)") {
            HStack(spacing: 10) {
                Text("splash").foregroundStyle(.srWhite).srStyled(.chip(background: .splash))
                Text("srWhite").srStyled(.chip(background: .srWhite))
                Text("srLightGray").srStyled(.chip(background: .srLightGray))
            }
        }
    }

    var avatarSection: some View {
        section("Avatars — srStyled(.avatar)") {
            HStack(spacing: 14) {
                ForEach([21.0, 25.0, 40.0, 50.0], id: \.self) { size in
                    Image(.default)
                        .resizable()
                        .srStyled(.avatar(size: size))
                }
                Image(.default)
                    .resizable()
                    .srStyled(.avatar(size: 40, strokeWidth: 0.35, strokeInset: 0))
            }
        }
    }

    var componentSection: some View {
        section("Components") {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    SRTagBadge(text: "글쓴이")
                    SRTagBadge(text: "공지사항", background: .pointtext)
                    SRCountLabel(count: 12)
                }
                SRDivider()
                Image(.floatingButton)
                    .resizable()
                    .srStyled(.floatingButton())
            }
        }
    }
}

#Preview("Design System Catalog") {
    DesignSystemCatalogView()
}
#endif
