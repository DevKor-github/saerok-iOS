# Architecture Decision Records

## 철학
기능 단위 독립성과 테스트 가능성을 유지하면서 빠른 개발 속도를 확보한다. Apple 네이티브 스택을 최우선으로 선택하고, 외부 의존성은 명확한 이유가 있을 때만 도입한다. 복잡한 추상화보다 작동하는 최소 구현을 선택하되, 레이어 간 경계는 명확히 유지한다.

---

### ADR-001: MVVM + Clean Architecture (레이어드 아키텍처) 채택
**결정**: View → ViewModel → Interactor → Repository → Network/Storage 5계층 구조 채택  
**이유**: 기능이 증가해도 비즈니스 로직(Interactor)과 데이터 접근(Repository)이 UI와 분리되어 있어 독립적으로 테스트 가능하다. Interactor는 프로토콜 기반이므로 Mock 구현체로 교체가 쉬워 프리뷰·단위 테스트에서 네트워크 없이 동작 검증이 가능하다.  
**트레이드오프**: 단순 CRUD 화면에서도 4~5개 파일(View, ViewModel, Interactor, Repository, Model)을 만들어야 해 초기 코드량이 증가한다. 레이어 경계를 잘못 이해하면 로직이 View나 Repository에 흘러들기 쉽다.

---

### ADR-002: SwiftUI + @Observable 선택 (UIKit 대신)
**결정**: 모든 UI를 SwiftUI로 구현하고, ViewModel 상태 관찰에 iOS 17+ `@Observable` 매크로 사용  
**이유**: 선언형 UI로 상태-화면 동기화 코드를 제거하고 개발 속도를 높인다. `@Observable`은 ObservableObject보다 불필요한 렌더링이 적고, Xcode 프리뷰와의 연동이 자연스럽다.  
**트레이드오프**: iOS 17 미만 지원 불가. UIKit 컴포넌트가 필요한 엣지 케이스(예: 복잡한 지도 인터랙션, 커스텀 텍스트 에디터)에서 UIViewRepresentable 브릿징이 필요하다.

---

### ADR-003: DIContainer + @Environment 기반 의존성 주입 (3rd-party DI 프레임워크 대신)
**결정**: `AppEnvironment.bootstrap()`에서 모든 의존성을 조립하고, `DIContainer`를 SwiftUI `@Environment`로 뷰 트리에 전파  
**이유**: Swinject 등 외부 DI 프레임워크 없이 Apple 기본 기능만으로 동일한 효과를 얻는다. 루트에서 한 번만 주입하면 하위 뷰 어디서든 꺼내 쓸 수 있어 객체를 수동으로 전달(prop drilling)할 필요가 없다. 테스트·프리뷰에서는 stub 구현체를 주입해 네트워크 없이 UI 확인이 가능하다.  
**트레이드오프**: `@Environment` 접근은 런타임에 타입을 조회하므로 누락 시 컴파일 에러 대신 런타임 에러가 발생한다. 의존성 그래프가 복잡해질수록 `bootstrap()` 함수가 비대해진다.

---

### ADR-004: AppCoordinator 패턴으로 네비게이션 중앙 관리
**결정**: 화면 전환 로직을 `AppCoordinator`에 집중하고, ViewModel에서는 Coordinator를 통해서만 라우팅 요청  
**이유**: 뷰가 다음 화면을 직접 알지 않아도 되므로 화면 간 결합도가 낮아진다. 딥링크·알림 등 외부 진입점에서도 Coordinator 한 곳을 수정해 모든 네비게이션 흐름을 제어할 수 있다. ViewModel 팩토리 역할도 겸하여 의존성 생성 책임을 한 곳으로 모은다.  
**트레이드오프**: 화면 전환마다 Coordinator를 거쳐야 하므로 간단한 팝업·시트도 라우팅 케이스로 등록해야 해 초기 설계 비용이 있다.

---

### ADR-005: Combine 기반 `Store<T>`로 전역 상태 관리
**결정**: `AppState`를 `Store<AppState>` (`CurrentValueSubject` 래퍼)로 관리하고, `KeyPath` 서브스크립트로 타입 안전하게 접근  
**이유**: TCA·Redux 등 외부 상태관리 프레임워크 없이 Combine만으로 단방향 데이터 흐름을 구현한다. `bulkUpdate()`로 여러 상태를 한 트랜잭션에 변경해 불필요한 중간 렌더링을 방지한다.  
**트레이드오프**: Combine에 대한 이해가 부족하면 메모리 누수(AnyCancellable 미해제)가 발생하기 쉽다. 전역 상태가 커질수록 `AppState` 구조체가 비대해진다.

---

### ADR-006: SwiftData 로컬 영속성 (CoreData/Realm 대신)
**결정**: 로컬 캐싱 및 영속성 저장에 iOS 17+ SwiftData 사용  
**이유**: CoreData보다 Swift-native API로 보일러플레이트가 적고, `@Model` 매크로로 모델 정의가 간결하다. 앱이 iOS 17을 최소 지원 버전으로 타겟하므로 호환성 문제가 없다. Realm은 추가 외부 의존성을 도입하므로 제외했다.  
**트레이드오프**: SwiftData는 CoreData 대비 성숙도가 낮아 복잡한 마이그레이션·쿼리 최적화에서 제약이 있다. CloudKit 연동이 필요할 때 CoreData만큼 검증된 사례가 부족하다.

---

### ADR-007: S3 Presigned URL 방식으로 이미지 업로드
**결정**: 이미지 업로드 시 백엔드에서 S3 Presigned URL을 발급받아 클라이언트가 S3에 직접 업로드  
**이유**: 이미지 바이너리를 백엔드 서버를 거치지 않아 서버 트래픽·부하가 줄어든다. 업로드 실패 시 새록 등록 자체를 롤백하는 흐름으로 데이터 정합성을 보장한다.  
**트레이드오프**: 클라이언트가 업로드 성공 여부를 직접 처리해야 하므로 에러 핸들링 흐름이 복잡해진다(Presigned URL 발급 → S3 업로드 → 메타데이터 등록 → 실패 시 롤백). 네트워크 단절 중간 단계에서 부분 실패 시나리오를 별도로 고려해야 한다.

---

### ADR-008: Alamofire 기반 HTTP 네트워킹 (URLSession 직접 사용 대신)
**결정**: 네트워크 레이어를 `SRNetworkService` 프로토콜로 추상화하고 내부 구현은 Alamofire 5 사용  
**이유**: 인터셉터·리트라이·멀티파트 업로드 등 반복적인 네트워킹 보일러플레이트를 Alamofire가 대신 처리한다. 프로토콜 추상화 덕분에 테스트 시 URLSession 레벨 Mocking 없이 서비스 구현체만 교체 가능하다.  
**트레이드오프**: Swift Concurrency 시대에 URLSession async/await만으로도 충분한 요구사항에서 불필요한 외부 의존성이 된다. Alamofire 버전 업그레이드 시 인터페이스 변화에 대응해야 하는 유지보수 비용이 있다.
