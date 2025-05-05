//
//  CollectionDetailView.swift
//  saerok
//
//  Created by HanSeung on 4/12/25.
//


import Combine
import SwiftUI

struct CollectionDetailView: View {
    private let collectionBird: Local.CollectionBird
    
    // MARK:  Dependencies
    
    @Environment(\.injected) private var injected: DIContainer
    
    // MARK: Navigation

    @Binding var path: NavigationPath
    
    // MARK: - Init

    init(_ bird: Local.CollectionBird, path: Binding<NavigationPath>) {
        self.collectionBird = bird
        self._path = path
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 11) {
            navigationBar
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    imageSection
                    contentSection
                        .padding(SRDesignConstant.defaultPadding)
                }
            }
        }
        .regainSwipeBack()
    }
}

private extension CollectionDetailView {
    @ViewBuilder
    var imageSection: some View {
        if !collectionBird.imageURL.isEmpty {
            TabView {
                ForEach(collectionBird.imageURL, id: \.self) { url in
                    ReactiveAsyncImage(
                        url: url,
                        scale: .medium,
                        quality: 1.0,
                        downsampling: true
                    )
                    .frame(height: 300)
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .frame(height: 300)
        } else if let imageData = collectionBird.imageData.first {
            TabView {
                ForEach(collectionBird.imageData, id: \.self) { data in
                    Image(uiImage: UIImage(data: data) ?? .birdPreview)
                        .resizable()
                        .clipShape(Rectangle())
                    .frame(height: 300)
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .frame(height: 300)
            
        } else {
            Text("이미지 없음")
                .frame(height: 300)
        }
    }
    
    var contentSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text("관찰정보")
                    .font(.SRFontSet.h2)
                    .fontWeight(.bold)
                
                Spacer()
                
                NavigationLink {
                    BirdDetailView(collectionBird.bird ?? .mockData[0], path: $path)
                } label: {
                    Text("도감 보기")
                        .font(.SRFontSet.h3)
                        .bold()
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color.main)
                        .foregroundStyle(.srWhite)
                        .cornerRadius(8)
                }
                
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("발견 일시")
                        .font(.SRFontSet.h6)
                        .foregroundStyle(.secondary)
                    Text(collectionBird.date.toFullString)
                        .font(.SRFontSet.h3)
                }
                HStack {
                    Text("발견 장소")
                        .font(.SRFontSet.h6)
                        .foregroundStyle(.secondary)
                    Text(collectionBird.locationDescription ?? "위치 정보 없음")
                        .font(.SRFontSet.h3)
                }
            }
            
            if let note = collectionBird.note, !note.isEmpty {
                Text(note)
                    .font(.SRFontSet.h6)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 13)
                    .padding(.horizontal, 17)
                    .background(Color.background)
                    .cornerRadius(8)
            }
            Spacer()
        }
    }
    
    var navigationBar: some View {
        NavigationBar(
            leading: {
                HStack(spacing: 16) {
                    Button {
                        path.removeLast()
                    } label: {
                        Image(.chevronLeft)
                    }
                    .buttonStyle(.plain)
                    
                    VStack(alignment: .leading) {
                        Text((collectionBird.bird?.name ?? collectionBird.customName)!)
                            .font(.SRFontSet.h2)
                        Text(collectionBird.bird?.scientificName ?? "")
                            .font(.SRFontSet.h3)
                            .foregroundStyle(.gray)
                    }
                }
            }
        )
    }
}

#Preview {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    appDelegate.rootView
}
