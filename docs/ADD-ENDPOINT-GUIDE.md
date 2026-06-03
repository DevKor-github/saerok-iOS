# API 엔드포인트 추가 가이드

새 API를 연동할 때 반드시 이 순서대로 작업한다.

> **파일 생성 순서**: DTO → Local 모델 → Endpoint → Repository → Interactor

---

## 1단계: API 문서 읽기

연동 전에 다음 항목을 확인한다.

| 항목 | 확인할 것 |
|------|----------|
| HTTP 메서드 | GET / POST / PATCH / DELETE |
| 경로 | `/api/v1/...` 에서 버전 prefix 제거한 부분 |
| 인증 | required / optional / none |
| 쿼리 파라미터 | 이름, 타입, 필수 여부, 쌍으로만 유효한 파라미터 여부 |
| 요청 바디 | 필드 이름, 타입, 필수 여부 |
| 응답 스키마 | 최상위 래퍼 구조 (`items` + `hasNext`, 단일 객체 등), 각 필드 이름·타입·nullable 여부 |
| 에러 케이스 | 400/401/403/404 등 앱에서 처리해야 하는 경우 |

---

## 2단계: DTO 작성

**위치**: `saerok/Sources/Repositories/Models/DTO/{도메인} API/`

```swift
// FreeBoardPostsResponse.swift
extension DTO {
    struct CommunityFreeboardPostsResponse: Decodable {
        let items: [FreeBoardPostItem]
        let hasNext: Bool
    }

    struct FreeBoardPostItem: Decodable {
        let postId: Int
        let userId: Int
        let nickname: String
        let profileImageUrl: String?   // nullable이면 Optional
        let content: String
        let commentCount: Int
        let isMine: Bool
        let createdAt: String          // 날짜는 String으로 받고 Local에서 변환
        let updatedAt: String
    }
}
```

**규칙**
- API 필드명을 그대로 camelCase로 옮긴다 (snake_case → camelCase 자동 변환이 없으므로 API가 camelCase이면 그대로).
- nullable 필드는 `Optional`로 선언한다.
- 날짜는 `String`으로 받고 Local 모델 변환 시 `Date`로 파싱한다.
- 기존 공유 타입(`CommunityItem` 등)이 있으면 새 파일을 만들지 않고 기존 파일에 추가한다.

---

## 3단계: Local 모델 작성

**위치**: `saerok/Sources/Repositories/Models/Local/{도메인}/`

```swift
// FreeBoardPost.swift
extension Local {
    struct FreeBoardPost: Identifiable, Equatable {
        let id: Int               // DTO의 postId → id로 매핑
        let userId: Int
        let nickname: String
        let profileImageUrl: String?
        let content: String
        let commentCount: Int
        let isMine: Bool
        let createdAt: Date       // String → Date 변환 완료
        let updatedAt: Date
    }
}

extension Local.FreeBoardPost {
    static func from(dto: DTO.FreeBoardPostItem) -> Self {
        .init(
            id: dto.postId,
            userId: dto.userId,
            nickname: dto.nickname,
            profileImageUrl: dto.profileImageUrl,
            content: dto.content,
            commentCount: dto.commentCount,
            isMine: dto.isMine,
            createdAt: DateFormatter.iso8601.date(from: dto.createdAt) ?? .now,
            updatedAt: DateFormatter.iso8601.date(from: dto.updatedAt) ?? .now
        )
    }
}
```

**규칙**
- View가 직접 사용하는 타입이므로 앱 관점의 이름을 쓴다 (`postId` → `id`).
- `Identifiable` 채택 시 `id` 프로퍼티 이름을 맞춘다.
- 날짜 파싱: ISO8601 형식이면 `DateFormatter.iso8601`, `"yyyy-MM-dd"` 형식이면 별도 `DateFormatter` 생성.
- 변환 실패 fallback은 `.now` 또는 문맥에 맞는 기본값을 쓴다.

---

## 4단계: SREndpoint에 추가

**위치**: `saerok/Sources/Network/EndPoint/SREndpoint.swift`

`SREndpoint`는 **struct**이고, 각 API는 도메인별 `extension SREndpoint`의 **static factory 하나**로 정의한다. 하나의 API에 필요한 모든 속성이 한 블록에 모이므로, 해당 도메인 `// MARK:` 섹션에 함수 하나만 추가하면 된다. (예전처럼 여러 `switch`를 오가며 수정하지 않는다.)

### 호출부에서 인자가 있으면 `static func`, 없으면 `static var`

```swift
// MARK: - Community API
extension SREndpoint {
    static func communityFreeboardPosts(page: Int? = nil, size: Int? = nil) -> SREndpoint {
        SREndpoint(
            path: "community/freeboard/posts",
            method: .get,                 // 기본값 .get — GET이면 생략 가능
            auth: .ifLoggedIn,            // .none / .required / .ifLoggedIn
            query: pageQuery(page: page, size: size),
            response: DTO.CommunityFreeboardPostsResponse.self
        )
    }
}
```

### `init` 파라미터 한눈에

| 파라미터 | 의미 | 기본값 |
|----------|------|--------|
| `path` | 경로 (버전 prefix 제거). 앞에 `/`를 붙이지 않는다 | (필수) |
| `method` | `.get` / `.post` / `.patch` / `.delete` | `.get` |
| `auth` | 인증 정책 (아래 표 참고) | `.none` |
| `query` | 쿼리 파라미터 `[String: String]?` | `nil` |
| `body` | 요청 바디 `Data?` — `jsonBody(...)` 헬퍼로 인코딩 | `nil` |
| `json` | `Content-Type: application/json` 헤더 부착 여부. 바디가 JSON이면 `true` | `false` |
| `response` | 디코딩할 응답 타입. **응답 바디가 없으면 생략** (기본 `EmptyResponse`) | `EmptyResponse.self` |

### `auth` 정책

| API 인증 | 값 |
|----------|------|
| required (항상 토큰) | `.required` |
| none (공개) | `.none` (생략 가능) |
| optional (있으면 부착) | `.ifLoggedIn` |

### 바디가 있는 경우 — `jsonBody` 헬퍼 사용

```swift
// Encodable DTO 바디
static func createFreeBoardPost(body: DTO.CreateFreeBoardPostRequest) -> SREndpoint {
    SREndpoint(
        path: "community/freeboard/posts",
        method: .post,
        auth: .required,
        body: jsonBody(body),   // Encodable → Data
        json: true,
        response: DTO.CreateFreeBoardPostResponse.self
    )
}

// 단일 필드 등 모델 없이 딕셔너리 바디
static func suggestBird(collectionId: Int, birdId: Int) -> SREndpoint {
    SREndpoint(
        path: "collections/\(collectionId)/bird-id-suggestions",
        method: .post,
        auth: .required,
        body: jsonBody(["birdId": birdId]),   // [String: Any] → Data
        json: true,
        response: DTO.SuggestResponse.self
    )
}
```

### 페이지네이션 쿼리 — `pageQuery` / `searchQuery` 헬퍼

`page`·`size`가 **둘 다 있을 때만** 쿼리를 붙이는 규칙은 파일 하단의 헬퍼로 처리한다. 직접 `if let` 분기를 작성하지 말고 재사용한다.

```swift
query: pageQuery(page: page, size: size)              // page+size 쌍, 둘 중 하나라도 nil이면 쿼리 없음
query: searchQuery(query: q, page: page, size: size)  // q는 항상, page+size는 쌍일 때만
```

> 응답 바디가 없는 API(`delete*`, `report*` 등)는 `response:`를 생략하면 자동으로 `EmptyResponse`가 된다. 예전 `switch`의 `default:` 함정(추가를 깜빡하면 조용히 잘못된 타입으로 디코딩)이 사라졌으므로, 응답 타입은 항상 호출 지점에서 명시적으로 보인다.

---

## 5단계: Repository 추가

**위치**: `saerok/Sources/Repositories/{도메인}Repository.swift`

프로토콜과 구현체(`MainRepository` extension)를 함께 작성한다.

```swift
// 프로토콜
protocol CommunityRepository {
    // ... 기존 메서드
    func fetchFreeboardPosts(page: Int?, size: Int?) async throws -> DTO.CommunityFreeboardPostsResponse
}

// 구현체
extension MainRepository: CommunityRepository {
    func fetchFreeboardPosts(page: Int?, size: Int?) async throws -> DTO.CommunityFreeboardPostsResponse {
        try await networkService.performSRRequest(
            .communityFreeboardPosts(page: page, size: size)
        )
    }
}
```

---

## 6단계: Interactor 추가

**위치**: `saerok/Sources/Interactors/{도메인}Interactor.swift`

프로토콜, 실구현체, Mock 세 곳 모두 작성한다.

```swift
// 프로토콜
protocol CommunityInteractor {
    // ... 기존 메서드
    func fetchFreeboardPosts(page: Int?, size: Int?) async throws -> (items: [Local.FreeBoardPost], hasNext: Bool)
}

// 실구현체
struct CommunityInteractorImpl: CommunityInteractor {
    func fetchFreeboardPosts(page: Int?, size: Int?) async throws -> (items: [Local.FreeBoardPost], hasNext: Bool) {
        let dto = try await repository.fetchFreeboardPosts(page: page, size: size)
        return (items: dto.items.map { Local.FreeBoardPost.from(dto: $0) }, hasNext: dto.hasNext)
    }
}

// Mock
struct MockCommunityInteractorImpl: CommunityInteractor {
    func fetchFreeboardPosts(page: Int?, size: Int?) async throws -> (items: [Local.FreeBoardPost], hasNext: Bool) {
        throw CommunityInteractorError.notImplementedInMock
    }
}
```

**규칙**
- Interactor는 DTO를 Local 모델로 변환한 뒤 반환한다. ViewModel은 Local 모델만 다룬다.
- 비즈니스 로직(차단 유저 필터링, 정렬 등)이 필요하면 Interactor 내 private 메서드로 작성한다.
- Mock은 `notImplementedInMock` 에러를 던지거나 프리뷰용 더미 데이터를 반환한다.

---

## 체크리스트

```
[ ] DTO 파일 생성 (nullable 처리, 날짜는 String)
[ ] Local 모델 파일 생성 (from(dto:) 변환 포함)
[ ] SREndpoint static factory 추가 (도메인 MARK 섹션에 함수 하나)
[ ]   - path / method / auth 지정
[ ]   - 바디는 jsonBody(...), 페이지 쿼리는 pageQuery/searchQuery 헬퍼 사용
[ ]   - response 타입 지정 (응답 바디 없으면 생략 → EmptyResponse)
[ ] Repository 프로토콜 메서드 추가
[ ] Repository MainRepository 구현 추가
[ ] Interactor 프로토콜 메서드 추가
[ ] CommunityInteractorImpl 구현 추가
[ ] MockCommunityInteractorImpl 구현 추가
```
