//
//  SRPopup.swift
//  saerok
//
//  Created by HanSeung on 5/13/25.
//

import SwiftUI

/// 팝업을 구성하기 위한 데이터 모델.
/// View에서 팝업을 직접 생성하지 않고, 이 설정 객체만 전달하면
/// `srPopup` modifier가 실제 팝업 View를 생성한다.
struct PopupConfig {
    /// 팝업 제목
    let title: String
    
    /// 팝업 본문 메시지
    let message: String
    
    /// 버튼 구성 (1개 또는 2개)
    let buttons: PopupButtonLayout
}

/// 팝업 버튼 레이아웃 정의.
/// 현재는 단일 버튼 또는 좌우 2개 버튼만 지원한다.
enum PopupButtonLayout {
    
    /// 버튼 1개 (보통 확인)
    case single(PopupButtonConfig)
    
    /// 버튼 2개 (예: 취소 / 확인)
    case double(PopupButtonConfig, PopupButtonConfig)
}

/// 개별 버튼의 설정 모델
struct PopupButtonConfig {
    
    /// 버튼에 표시될 텍스트
    let title: String
    
    /// 버튼 스타일 (confirm / delete / bordered 등)
    let style: SRAlertStyle
    
    /// 버튼 탭 시 실행되는 액션
    let action: () -> Void
}

/// 실제 팝업 UI를 그리는 View.
/// `PopupConfig`의 데이터를 기반으로 화면에 팝업을 렌더링한다.
struct SRPopup: View {
    
    /// 팝업 제목
    let title: String
    
    /// 팝업 메시지
    let message: String
    
    /// 버튼 레이아웃
    let buttons: PopupButtonLayout
    
    var body: some View {
        VStack(spacing: 0) {
            
            /// 상단 경고 아이콘
            Image.SRIconSet.alert
                .frame(.defaultIconSizeLarge, tintColor: .splash)
                .padding(.bottom, 15)
            
            /// 제목 + 메시지 영역
            VStack(alignment: .center, spacing: 6) {
                Text(title)
                    .font(.SRFontSet.body3)
                
                Text(message)
                    .font(.SRFontSet.body2)
                    .foregroundStyle(.secondary)
            }
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.bottom, 20)
            
            /// 버튼 영역
            buttonSection
        }
        .padding()
        .frame(maxWidth: 300)
        .background(Color.srWhite)
        .cornerRadius(20)
        .padding()
    }
    
    /// 버튼 레이아웃을 실제 버튼 View로 변환하는 영역
    @ViewBuilder
    private var buttonSection: some View {
        switch buttons {
            
        /// 버튼이 하나일 경우
        case .single(let button):
            popupButton(button)
                .frame(maxWidth: .infinity)
            
        /// 버튼이 두 개일 경우 좌우 배치
        case .double(let leading, let trailing):
            HStack {
                popupButton(leading)
                popupButton(trailing)
            }
        }
    }
    
    /// PopupButtonConfig를 실제 Button View로 변환
    @ViewBuilder
    private func popupButton(_ config: PopupButtonConfig) -> some View {
        Button(config.title, action: config.action)
            .srStyled(.alert(config.style))
    }
}

/// View에 팝업을 표시하기 위한 modifier.
/// 어떤 View 위에서도 동일한 방식으로 팝업을 띄울 수 있다.
extension View {
    
    /// SRPopup을 overlay 형태로 표시하는 modifier
    ///
    /// - Parameters:
    ///   - isPresented: 팝업 표시 여부
    ///   - config: 팝업 설정 객체 (nil이면 표시하지 않음)
    func srPopup(
        isPresented: Binding<Bool>,
        config: PopupConfig?
    ) -> some View {
        ZStack {
            self

            /// 팝업이 표시될 때만 overlay 추가
            if isPresented.wrappedValue, let config {
                
                /// 배경 dim 처리
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    
                    /// 배경 탭 시 팝업 닫기
                    .onTapGesture {
                        isPresented.wrappedValue = false
                    }
                    .transition(.opacity)
                    .zIndex(1)

                /// 실제 팝업 View
                SRPopup(
                    title: config.title,
                    message: config.message,
                    buttons: config.buttons
                )
                .transition(.asymmetric(insertion: .scale, removal: .opacity))
                .zIndex(2)
            }
        }
        
        /// 팝업 등장/사라짐 애니메이션
        .animation(.spring(duration: 0.2), value: isPresented.wrappedValue)
    }
}
