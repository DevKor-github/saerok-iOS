//
//  SuggestionCell.swift
//  saerok
//
//  Created by HanSeung on 7/14/25.
//

import SwiftUI

struct SuggestionCell: View {
    @Binding var item: Local.BirdSuggestion
    var selectedId: Int?
    let isMine: Bool
    let onAgree: () -> Void
    let onDisagree: () -> Void
    let onAdopt: (() -> Void)? 
    let onTap: () -> Void
    
    private var isSelcted: Bool { selectedId == item.bird.id }
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                Text(item.bird.name)
                    .font(.SRFontSet.body3)
                Text(item.bird.scientificName)
                    .font(.SRFontSet.caption1)
                    .foregroundStyle(.srGray)
            }
            .padding(.top, 2)
            .padding(.bottom, 5)
            .padding(.horizontal, 19)
            
            Spacer()
            
            if isMine {
                mySection
            } else {
                voteSection
            }
        }
        .background(Color.srWhite)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .inset(by: 0.5)
                .stroke(isSelcted ? Color.splash : .clear, lineWidth: 1)
        )
        .cornerRadius(20)
        .padding(.horizontal, SRDesignConstant.defaultPadding)
        .onTapGesture {
            onTap()
        }
    }
    
    private var voteSection: some View {
        HStack(spacing: 7) {
            VStack(spacing: 2) {
                Button(action: onAgree) {
                    ZStack {
                        Circle()
                            .fill(item.isAgreed ? .splash : .glassWhite)
                            .frame(width: 40, height: 40)
                            .overlay(
                                Circle()
                                    .stroke(Color.srLightGray, lineWidth: 0.35)
                            )
                        
                        Image.SRIconSet.o
                            .frame(
                                .defaultIconSizeLarge,
                                tintColor: item.isAgreed ? .srWhite : .splash
                            )
                    }
                }
                
                Text("\(item.agreeCount)")
                    .font(.SRFontSet.caption1_2)
            }
            
            VStack(spacing: 2) {
                Button(action: onDisagree) {
                    ZStack {
                        Circle()
                            .fill(item.isDisagreed ? .iconRed : .glassWhite)
                            .frame(width: 40, height: 40)
                            .overlay(
                                Circle()
                                    .stroke(Color.srLightGray, lineWidth: 0.35)
                            )
                        Image.SRIconSet.x
                            .frame(
                                .defaultIconSize,
                                tintColor: item.isDisagreed ? .srWhite : .iconRed
                            )
                    }
                }
                
                Text("\(item.disagreeCount)")
                    .font(.SRFontSet.caption1_2)
            }
        }
        .padding(11)
    }
    
    private var mySection: some View {
        VStack(alignment: .center, spacing: 7) {
            AdoptButton(onAdopt: onAdopt)
            
            HStack(spacing: 18) {
                HStack(spacing: 5) {
                    Image.SRIconSet.o
                        .frame(size: CGSize(width: 14, height: 14))
                    
                    Text("\(item.agreeCount)")
                        .font(.SRFontSet.caption1_2)
                }
                
                HStack(spacing: 5) {
                    Image.SRIconSet.x
                        .frame(size: CGSize(width: 10, height: 10))
                    
                    Text("\(item.disagreeCount)")
                        .font(.SRFontSet.caption1_2)
                }
            }
        }
        .padding(11)
    }
    
    private struct AdoptButton: View {
        let onAdopt: (() -> Void)?
        @State private var isOn: Bool = false
        
        var body: some View {
            Button {
                (onAdopt ?? {})()
                isOn.toggle()
            } label: {
                HStack(spacing: 8) {
                    Image.SRIconSet.adopt
                        .frame(.defaultIconSize, tintColor: isOn ? .white : .black)
                    
                    Text("채택")
                        .font(.SRFontSet.button2)
                }
                .padding(.vertical, 9)
                .padding(.leading, 12)
                .padding(.trailing, 15)
                .frame(height: 40, alignment: .center)
                .foregroundStyle(isOn ? .white : .black)
                .background(isOn ? Color.splash : Color.srWhite)
                .cornerRadius(30.5)
                .overlay(
                    RoundedRectangle(cornerRadius: 30.5)
                        .inset(by: 0.17)
                        .stroke(Color.srGray, lineWidth: 0.35)
                )
            }
            .buttonStyle(.plain)
        }
    }
}
