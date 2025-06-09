//
//  FilterBar.swift
//  saerok
//
//  Created by HanSeung on 4/22/25.
//


import SwiftUI

struct FilterBar: View {
    @Binding var showSeasonSheet: Bool
    @Binding var showHabitatSheet: Bool
    @Binding var showSizeSheet: Bool
    @Binding var filterKey: BirdFilter

    private var isActive: Bool {
        filterKey.selectedHabitats.count > 0 ||
        filterKey.selectedSeasons.count > 0 ||
        filterKey.selectedSizes.count > 0
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                FilterButton<Season>(
                    icon: Image.SRIconSet.season,
                    iconSelected: Image.SRIconSet.seasonWhite,
                    placeholder: "계절",
                    title: "계절 선택",
                    isPresented: $showSeasonSheet,
                    selection: $filterKey.selectedSeasons,
                    detents: [.fraction(0.4)],
                    style: .compact
                )
                FilterButton<Habitat>(
                    icon: Image.SRIconSet.habitat,
                    iconSelected: Image.SRIconSet.habitatWhite,
                    placeholder: "서식지",
                    title: "서식지 선택",
                    isPresented: $showHabitatSheet,
                    selection: $filterKey.selectedHabitats,
                    detents: [.fraction(0.6)],
                    style: .adaptive
                )
                FilterButton<BirdSize>(
                    icon: Image.SRIconSet.size,
                    iconSelected: Image.SRIconSet.sizeWhite,
                    placeholder: "크기",
                    title: "크기 선택",
                    isPresented: $showSizeSheet,
                    selection: $filterKey.selectedSizes,
                    detents: [.fraction(0.45)],
                    style: .birdSize
                )
                
                if isActive {
                    Button {
                        filterKey.reset()
                    } label: {
                        Image.SRIconSet.reset
                            .frame(.defaultIconSize)
                    }
                    .srStyled(.filterButton(isActive: false))
                }
            
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 1)
        }
    }
}
