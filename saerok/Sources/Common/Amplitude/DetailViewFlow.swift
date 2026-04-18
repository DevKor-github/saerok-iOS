//
//  DetailViewFlow.swift
//

import Foundation

/// DetailViewFlow - 새록 상세 화면의 사용자 플로우를 추적하는 매니저
/// 각 상세 화면 세션마다 하나의 인스턴스가 생성되어 사용자의 행동과 타이밍을 기록합니다.
final class DetailViewFlow {
    
    // MARK: - Properties
    
    /// 상세 화면 세션 고유 ID (UUID)
    let detailViewId: String
    
    /// 레코드 ID
    let recordId: String
    
    /// 진입 경로
    let entrySource: EntrySource
    
    /// 진입 화면
    let screen: Screen
    
    /// 본인 레코드 여부
    let isOwnRecord: Bool
    
    /// 목록에서의 좋아요 수
    let listLikeCount: Int
    
    /// 목록에서의 댓글 수
    let listCommentCount: Int
    
    /// UI 변형 버전 (A/B 테스트용)
    let detailUiVariant: DetailUIVariant
    
    // MARK: - Timestamps
    
    /// 상세 화면 탭 시각
    private(set) var detailTapTs: Date
    
    /// 상세 화면 로드 완료 시각
    private(set) var detailLoadedTs: Date?
    
    // MARK: - State Flags
    
    /// 이미지 로드 완료 여부
    private(set) var imageLoaded: Bool = false
    
    /// 댓글 로드 완료 여부
    private(set) var commentLoaded: Bool = false
    
    /// 사용자 인터랙션 발생 여부 (좋아요, 댓글 등)
    private(set) var hadInteraction: Bool = false
    
    // MARK: - Initialization
    
    init(
        recordId: String,
        entrySource: EntrySource,
        screen: Screen,
        isOwnRecord: Bool,
        listLikeCount: Int,
        listCommentCount: Int,
        detailUiVariant: DetailUIVariant = .variantA
    ) {
        self.detailViewId = UUID().uuidString
        self.recordId = recordId
        self.entrySource = entrySource
        self.screen = screen
        self.isOwnRecord = isOwnRecord
        self.listLikeCount = listLikeCount
        self.listCommentCount = listCommentCount
        self.detailUiVariant = detailUiVariant
        self.detailTapTs = Date()
    }
    
    // MARK: - State Marking Methods
    
    /// 상세 화면 로드 완료 표시
    func markDetailLoaded() {
        detailLoadedTs = Date()
    }
    
    /// 이미지 로드 완료 표시
    func markImageLoaded() {
        imageLoaded = true
    }
    
    /// 댓글 로드 완료 표시
    func markCommentLoaded() {
        commentLoaded = true
    }
    
    /// 사용자 인터랙션 발생 표시
    func markHadInteraction() {
        hadInteraction = true
    }
    
    // MARK: - Duration Calculation Methods
    
    /// 탭부터 로드 완료까지 소요 시간 (ms)
    func loadDurationMs() -> Int {
        guard let loadedTs = detailLoadedTs else { return 0 }
        return Int(loadedTs.timeIntervalSince(detailTapTs) * 1000)
    }
    
    /// 로드 완료부터 좋아요까지 소요 시간 (ms)
    func viewToLikeMs() -> Int {
        guard let loadedTs = detailLoadedTs else { return 0 }
        return Int(Date().timeIntervalSince(loadedTs) * 1000)
    }
    
    /// 로드 완료부터 댓글 열기까지 소요 시간 (ms)
    func viewToCommentMs() -> Int {
        guard let loadedTs = detailLoadedTs else { return 0 }
        return Int(Date().timeIntervalSince(loadedTs) * 1000)
    }
    
    /// 탭부터 나가기까지 총 소요 시간 (ms)
    func viewToExitMs() -> Int {
        return Int(Date().timeIntervalSince(detailTapTs) * 1000)
    }
}
