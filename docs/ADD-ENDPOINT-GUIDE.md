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

총 **6군데**를 수정한다.

### 4-1. case 선언
```swift
// MARK: Community API
case communityFreeboardPosts(page: Int? = nil, size: Int? = nil)
```

### 4-2. `path`
```swift
case .communityFreeboardPosts: "community/freeboard/posts"
```

### 4-3. `method`
```swift
// GET 케이스 목록에 추가
case .communityFreeboardPosts: // 이미 .get 케이스에 포함
```

### 4-4. `requiresAuth`
| API 인증 | 처리 방법 |
|----------|----------|
| required | `true`를 반환하는 케이스 목록에 추가 |
| none | `default: return false`에 걸리므로 추가 불필요 |
| optional | 토큰이 있으면 전송: `case .communityFreeboardPosts: return TokenManager.shared.getAccessToken() != nil` |

### 4-5. `queryItems` / `requestBody`
```swift
// 쿼리 파라미터 (page, size 쌍)
case .communityFreeboardPosts(let page, let size):
    if let page, let size {
        return ["page": "\(page)", "size": "\(size)"]
    } else {
        return nil
    }
```
- POST/PATCH 바디는 `requestBody`에, GET 파라미터는 `queryItems`에 추가한다.
- page와 size는 API 문서에서 "둘 다 제공해야 함" 조건이 있으면 쌍으로만 처리한다.

### 4-6. `expectedResponseType`
```swift
case .communityFreeboardPosts:
    return DTO.CommunityFreeboardPostsResponse.self
```

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
[ ] SREndpoint case 선언
[ ] SREndpoint path 추가
[ ] SREndpoint method(GET/POST 등) 케이스에 추가
[ ] SREndpoint requiresAuth 처리
[ ] SREndpoint queryItems 또는 requestBody 추가
[ ] SREndpoint expectedResponseType 추가
[ ] Repository 프로토콜 메서드 추가
[ ] Repository MainRepository 구현 추가
[ ] Interactor 프로토콜 메서드 추가
[ ] CommunityInteractorImpl 구현 추가
[ ] MockCommunityInteractorImpl 구현 추가
```
