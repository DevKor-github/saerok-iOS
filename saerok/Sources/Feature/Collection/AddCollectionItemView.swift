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
    }
    
    // MARK:  Dependencies

    @Environment(\.injected) var injected
    @Environment(\.modelContext) var context
    
    // MARK:  Routable

    @State var routingState: Routing = .init()
    
    // MARK: Navigation
    
    @Binding var path: NavigationPath

    // MARK: View State

    @State var isDateSeclecting: Bool = false
    @State var selectedBird: Local.Bird?
    @State var defaultText: String = ""
    @State var note: String = ""
    @State var date: Date?
    var submittable: Bool { selectedBird != nil && !note.isEmpty && date != nil
    }
    
    
    @State private var selectedImages: [UIImage] = []
    @State private var isShowingImagePicker: Bool = false
    
    @FocusState var nameFocused: Bool
    @FocusState var dateFocused: Bool
    @FocusState var noteFocused: Bool
    
    var body: some View {
        navigationBar
        VStack(spacing: 20) {
            imageForm
            nameForm
            dateForm
            noteForm
            Spacer()
            submitButton
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, SRDesignConstant.defaultPadding)
        .onReceive(routingUpdate) { self.routingState = $0 }
        .navigationDestination(for: Route.self, destination: { route in
            switch route {
            case .findBird:
                CollectionSearchView(path: $path)
            }
        })
        .onChange(of: routingState.selectedBird) { _, selectedBird in
            self.selectedBird = selectedBird
        }
        .regainSwipeBack()
    }
}

private extension AddCollectionItemView {
    var imageForm: some View {
        VStack(alignment: .leading, spacing: 10) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Array(selectedImages.enumerated()), id: \.offset) { index, image in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipped()
                                .cornerRadius(10)
                                .overlay {
                                    Button(action: {
                                        // 사진 삭제
                                        selectedImages.remove(at: index)
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.gray)
                                            .background(Color.srWhite)
                                            .clipShape(Circle())
                                            .offset(x: 50, y: -50) // 버튼 위치 조정
                                    }
                                }
                    }
                    
                    Button {
                        isShowingImagePicker = true
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.border, style: StrokeStyle(lineWidth: 1, dash: [5]))
                                .frame(width: 100, height: 100)
                            Image(systemName: "plus")
                                .foregroundColor(.border)
                        }
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 10)
            }
            .sheet(isPresented: $isShowingImagePicker) {
                MultiImagePicker(selectedImages: $selectedImages)
            }
        }
    }
    
    var nameForm: some View {
        VStack(alignment: .leading) {
            Text("새 이름")
                .font(.SRFontSet.h4)
                .padding(.horizontal, 10)

            HStack {
                Text(selectedBird == nil ? "새 이름을 입력해주세요" : selectedBird!.name)
                    .foregroundStyle(selectedBird != nil ? .primary : .tertiary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Image.SRIconSet.magnifyingGlass.frame(.defaultIconSizeMedium)
                    .foregroundStyle(.border)
            }
            .padding(.leading, 20)
            .padding(.trailing, 10)
            .frame(height: 44)
            .srStyled(.textField(isFocused: $nameFocused))

        }
        .onTapGesture {
            path.append(Route.findBird)
        }
    }
    
    var dateForm: some View {
        VStack(alignment: .leading) {
            Text("발견 일시")
                .font(.SRFontSet.h4)
                .padding(.horizontal, 10)
            Text(date?.toFullString ?? "날짜를 선택해주세요")
                .foregroundStyle(date != nil ? .primary : .tertiary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 20)
                .padding(.trailing, 10)
                .frame(height: 44)
                .srStyled(.textField(isFocused: $dateFocused))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isDateSeclecting ? Color.main : .border, lineWidth:2)
                )
                .onTapGesture {
                    withAnimation {
                        isDateSeclecting.toggle()
                    }
                }
            
            if isDateSeclecting {
                DatePicker("", selection: Binding(
                    get: { date ?? Date() },
                    set: {
                        date = $0
                        isDateSeclecting.toggle()
                    }
                ), displayedComponents: .date)
                .datePickerStyle(.graphical)
            }
        }
    }
    
    var noteForm: some View {
        VStack(alignment: .leading) {
            Text("한 줄 평")
                .font(.SRFontSet.h4)
                .padding(.horizontal, 10)

                TextField("한 줄 평을 입력해주세요", text: $note)
                    .padding(20)
                    .frame(height: 44)
                    .srStyled(.textField(isFocused: $noteFocused))
                    .overlay(alignment: .topTrailing) {
                        Text("(\(note.count)/100)")
                            .font(.SRFontSet.h4)
                            .foregroundColor(.secondary)
                            .padding(.top, 48)
                            .onChange(of: note) { _, newValue in
                                if newValue.count > 100 {
                                    note = String(newValue.prefix(100))
                                }
                            }
                    }
        }
    }
    
    var submitButton: some View {
        Button {
            context.insert(Local.CollectionBird.init(
                bird: selectedBird,
                customName: nil,
                date: date.unsafelyUnwrapped,
                latitude: 0,
                longitude: 0,
                locationDescription: "우리 집 근처",
                note: note,
                imageURL: [],
                lastModified: Date(),
                images: selectedImages
            ))
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
                    .font(.SRFontSet.h1)
            },
            trailing: {
                Button {
                    path.removeLast()
                } label: {
                    Image.SRIconSet.xmark.frame(.defaultIconSizeSmall)
                }
                .buttonStyle(.plain)
            }
        )
    }
}

// MARK: - Routable

extension AddCollectionItemView {
    struct Routing: Equatable {
        var selectedBird: Local.Bird?
    }
    
    var routingUpdate: AnyPublisher<Routing, Never> {
        injected.appState.updates(for: \.routing.addCollectionItemView)
    }
    
    var routingBinding: Binding<Routing> {
        $routingState.dispatched(to: injected.appState, \.routing.addCollectionItemView)
    }
}

#Preview {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    appDelegate.rootView
}
