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
    private(set) var isOwnRecord: Bool

    /// 목록에서의 좋아요 수
    private(set) var listLikeCount: Int

    /// 목록에서의 댓글 수
    private(set) var listCommentCount: Int
    
    /// UI 변형 버전 (A/B 테스트용)
    let detailUiVariant: DetailUIVariant
    
    // MARK: - Timestamps
    
    /// 상세 화면 탭 시각
    private(set) var detailTapTs: Date
    
    /// 상세 화면 로드 완료 시각
    private(set) var detailLoadedTs: Date?

    /// 댓글창 열기 시각 (commenttosubmit_ms 기준점)
    private(set) var commentOpenedTs: Date?

    // MARK: - State Flags
    
    /// 이미지 로드 완료 여부
    private(set) var imageLoaded: Bool = false
    
    /// 댓글 로드 완료 여부
    private(set) var commentLoaded: Bool = false
    
    /// 사용자 인터랙션 발생 여부 (좋아요, 댓글 등)
    private(set) var hadInteraction: Bool = false

    /// 이탈 직전 마지막 행동 (퍼널 2). 기본값 .other
    private(set) var lastAction: LastAction = .other
    
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
    
    // MARK: - Record Info Update

    /// 데이터 로드 완료 후 레코드 정보를 갱신한다.
    /// 플로우를 재생성하지 않으므로 `detailViewId`·`detailTapTs`가 보존되어
    /// 퍼널 조인과 load_duration_ms 계산이 정확하게 유지된다.
    func updateRecordInfo(
        isOwnRecord: Bool,
        listLikeCount: Int,
        listCommentCount: Int
    ) {
        self.isOwnRecord = isOwnRecord
        self.listLikeCount = listLikeCount
        self.listCommentCount = listCommentCount
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

    /// 댓글창 열기 표시 (commenttosubmit_ms 기준점 + last_action)
    func markCommentOpened() {
        commentOpenedTs = Date()
        lastAction = .commentOpen
    }

    /// 이탈 직전 마지막 행동 갱신 (퍼널 2)
    func setLastAction(_ action: LastAction) {
        lastAction = action
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

    /// 댓글창 열기부터 올리기 버튼 탭까지 소요 시간 (ms)
    func commentToSubmitMs() -> Int {
        guard let openedTs = commentOpenedTs else { return 0 }
        return Int(Date().timeIntervalSince(openedTs) * 1000)
    }
}
