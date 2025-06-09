//
//  NetworkMonitor.swift
//  saerok
//
//  Created by HanSeung on 6/5/25.
//


import Combine
import Network
import SwiftUI

final class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()
    
    @Published private(set) var isConnected: Bool = true
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitorQueue")
    
    private init() {
        startMonitoring()
        setupAppStateObservers()
    }
    
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }
    
    private func stopMonitoring() {
        monitor.cancel()
    }
    
    private func setupAppStateObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil)
    }
    
    @objc private func didBecomeActive() {
        startMonitoring()
    }
    
    @objc private func didEnterBackground() {
        stopMonitoring()
    }
    
    // 주요 액션 전에 네트워크 상태 체크 메서드 (예: API 요청 전)
    func checkConnection() -> Bool {
        return isConnected
    }
}
