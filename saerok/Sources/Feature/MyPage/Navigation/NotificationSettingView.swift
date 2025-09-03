//
//  NotificationSettingView.swift
//  saerok
//
//  Created by HanSeung on 8/14/25.
//


import SwiftUI

struct NotificationSettingView: View {
    @Environment(\.injected) private var injected
    
    @Binding var path: NavigationPath
    
    @State private var settings: Local.NotificationSettings = .init()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            navigationBar
            
            toggleSection
            
            Spacer()
        }
        .regainSwipeBack()
        .onAppear {
            Task { @MainActor in
                let fetched = try await injected.interactors.user.fetchNotificationSetting()
                self.settings = fetched
            }
        }
    }
    
    @ViewBuilder
    private var toggleSection: some View {
        VStack(spacing: 0) {
            ForEach(Local.NotificationType.allCases, id: \.self) { type in
                notificationSettingItem(type)
            }
        }
        .padding(.horizontal, SRDesignConstant.defaultPadding)
    }
    
    var navigationBar: some View {
        NavigationBar(
            center: {
                Text("알림 설정")
                    .font(.SRFontSet.subtitle2)
            }, leading: {
                Button {
                    path.removeLast()
                } label: {
                    Image.SRIconSet.chevronLeft
                        .frame(.defaultIconSize)
                }
            })
    }
    
    private func notificationSettingItem(_ type: Local.NotificationType) -> some View {
        HStack(alignment: .center) {
            Text(type.title)
                .font(.SRFontSet.body2)
            
            Spacer()
            
            ToggleButton(isOff: Binding(
                get: { !settings[type] },
                set: { _ in }
            )) {
                Task {
                    do {
                        let newValue = try await injected.interactors.user.toggleNotificationSetting(type)
                        
                        withAnimation(.bouncy(duration: 0.4)) {
                            settings[type] = newValue
                        }
                    } catch {
                        print("알림 설정 업데이트 실패: \(error.localizedDescription)")
                    
                    }
                }
            }
            
        }
        .padding(.horizontal, 0)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .center)
    }
}
