//
//  AddCollectionItemView.swift
//  saerok
//
//  Created by HanSeung on 4/24/25.
//


import Combine
import SwiftUI

struct AddCollectionItemView: Routable {
    enum Route {
        case findBird
        case findLocation
    }
    
    // MARK:  Dependencies
    
    @Environment(\.injected) var injected
    @Environment(\.modelContext) var context

    // MARK:  Routable
    
    @State var routingState: Routing = .init()
    
    // MARK: Navigation
    
    @Binding var path: NavigationPath
    
    // MARK: View State
    
    @State private var showingAlert: Bool = false
    
    @State private var selectedImages: [UIImage] = []
    @State private var selectedBird: Local.Bird?
    @State private var selectedCoord: (Double, Double) = (0,0)
    @State private var address = "도로명 주소 없음"
    @State private var note: String = ""
    @State private var date: Date?
    
    private let networkService = SRNetworkServiceImpl()
    private var submittable: Bool {
        selectedBird != nil
        && !note.isEmpty
        && date != nil
        && selectedCoord != (0,0)
    }
    
    var body: some View {
        content
            .onReceive(routingUpdate) { self.routingState = $0 }
            .navigationDestination(for: Route.self, destination: { route in
                switch route {
                case .findBird:
                    CollectionSearchView(path: $path)
                case .findLocation:
                    FindPlaceView(selectedPosition: $selectedCoord, path: $path)
                }
            })
            .onChange(of: routingState.selectedBird) { _, selectedBird in
                self.selectedBird = selectedBird
            }
            .onChange(of: routingState.locationSelected) { _, newValue in
                if newValue {
                    requestAddress()
                }
            }
            .onAppear {
                injected.appState[\.routing.collectionView.addCollection] = false
            }
            .onDisappear {
                injected.appState[\.routing.addCollectionItemView.locationSelected] = false
            }
            .navigationBarHidden(true)
    }
}

private extension AddCollectionItemView {
    @ViewBuilder
    var content: some View {
        ZStack {
            VStack(spacing: 0) {
                navigationBar
                VStack(spacing: 20) {
                    ImageFormView(selectedImages: $selectedImages)
                    BirdNameFormView(selectedBird: selectedBird, path: $path)
                    LocationFormView(selectedCoord: $selectedCoord, path: $path, address: address)
                    DateFormView(date: $date)
                    NoteFormView(note: $note)
                    Spacer()
                    submitButton
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, SRDesignConstant.defaultPadding)
            }
            
            alertView
        }
    }
    
    @ViewBuilder
    var alertView: some View {
        if showingAlert {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    showingAlert = false
                }
            
            CustomPopup(
                title: "작성 중인 내용이 있습니다.",
                message: "이대로 나가면 변경사항이 저장되지 않습니다.\n취소하시겠습니까?",
                leading: .init(
                    title: "나가기",
                    action: {
                        showingAlert = false
                        path.removeLast()
                    },
                    style: .normal
                ),
                trailing: .init(
                    title: "계속하기",
                    action: {
                        showingAlert = false
                    },
                    style: .primary
                )
            )
        }
    }
    
    var submitButton: some View {
        Button {
            submitForm()
            path.removeLast()
        } label: {
            Text("종 추가")
                .font(.SRFontSet.button)
                .frame(maxWidth: .infinity)
        }
        .disabled(!submittable)
        .buttonStyle(.primary)
    }
    
    var navigationBar: some View {
        NavigationBar(
            leading: {
                Text("종추")
                    .font(.SRFontSet.headline1)
            },
            trailing: {
                Button {
                    withAnimation(.bouncy) {
                        showingAlert = true
                    }
                } label: {
                    Image.SRIconSet.delete.frame(.defaultIconSizeLarge)
                }
                .buttonStyle(.plain)
            }
        )
    }
}

// MARK: - Action Method

private extension AddCollectionItemView {
    func submitForm() {
        context.insert(Local.CollectionBird.init(
            bird: selectedBird,
            customName: nil,
            date: date.unsafelyUnwrapped,
            latitude: selectedCoord.0,
            longitude: selectedCoord.1,
            locationDescription: address,
            note: note,
            imageURL: [],
            lastModified: Date(),
            images: selectedImages
        ))
    }
    
    func requestAddress() {
        Task {
            let result: DTO.KakaoAddressResponse = try await networkService.fetchKakaoAPIResult(
                endpoint: .address(
                    lng: selectedCoord.0,
                    lat: selectedCoord.1
                )
            )
            address = result.documents.toLocal().first?.address ?? "도로명 주소 없음"
        }
    }
}

// MARK: - Routable

extension AddCollectionItemView {
    struct Routing: Equatable {
        var selectedBird: Local.Bird?
        var locationSelected: Bool = false
    }
    
    var routingUpdate: AnyPublisher<Routing, Never> {
        injected.appState.updates(for: \.routing.addCollectionItemView)
    }
    
    var routingBinding: Binding<Routing> {
        $routingState.dispatched(to: injected.appState, \.routing.addCollectionItemView)
    }
}

// MARK: - Constants

extension AddCollectionItemView {
    enum Constants {
        static let imageSize: CGFloat = 100
        static let imageCornerRadius: CGFloat = 10
        static let formHeight: CGFloat = 44
        static let maxNoteLength: Int = 100
        static let deleteButtonOffset: CGFloat = imageSize / 2
    }
}

#Preview {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    appDelegate.rootView
}
