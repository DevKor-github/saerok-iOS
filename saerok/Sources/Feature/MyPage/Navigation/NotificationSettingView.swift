//
//  NotificationSettingView.swift
//  saerok
//
//  Created by HanSeung on 8/14/25.
//

import SwiftUI

struct NotificationSettingView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @Environment(\.injected) private var injected
    
    @State private var showDeniedAlert: Bool = false
    @State private var hasCheckedPermissionOnce: Bool = false
    @State private var settings: Local.NotificationSettings = .init()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            navigationBar
            toggleSection
            Spacer()
        }
        .regainSwipeBack()
        .task {
            let isDenied = await PushNotificationManager.shared.isDeniedNotificationPermission()
            isDenied ? showDeniedAlert.toggle() : ()
            do {
                self.settings = try await injected.interactors.user.fetchNotificationSetting()
            } catch {
                await PushNotificationManager.shared.reRegisterDevice()
                self.settings = (try? await injected.interactors.user.fetchNotificationSetting()) ?? .init()
            } 
        }
        .alert("알림 권한이 꺼져 있습니다", isPresented: $showDeniedAlert) {
            Button("설정으로 이동") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("뒤로가기", role: .cancel) {
                coordinator.pop()
            }
        } message: {
            Text("알림을 받으려면 설정에서 알림 권한을 켜주세요.")
        }
    }
    
    @ViewBuilder
    private var toggleSection: some View {
        VStack(spacing: 0) {
            ForEach(
                Local.NotificationType.allCases.filter {
                    // 자유게시판 댓글·답글 알림 설정은 일단 숨김 처리
                    $0 != .adminMessage
//                        && $0 != .freeBoardComment
//                        && $0 != .freeBoardReply
                },
                id: \.self
            ) { type in
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
                    coordinator.pop()
                } label: {
                    Image.SRIconSet.chevronLeft
                        .frame(.default)
                }
                .srStyled(.borderedIconButton)
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
                        HapticManager.shared.trigger(.light)
                        let newValue = try await injected.interactors.user.toggleNotificationSetting(type)
                        withAnimation(.bouncy(duration: 0.4)) {
                            settings[type] = newValue
                            HapticManager.shared.trigger(.success)
                        }
                    } catch {
                        HapticManager.shared.trigger(.error)
                    }
                }
            }
            
        }
        .padding(.horizontal, 0)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .center)
    }
}
