import Foundation
import PlaygroundSupport

// 플레이그라운드가 비동기 작업을 기다리도록 설정
PlaygroundPage.current.needsIndefiniteExecution = true

// MARK: - Models

struct User: Codable {
    let id: String
    let name: String
    let email: String
    let isActive: Bool
}

struct Post: Codable {
    let id: String
    let userId: String
    let title: String
    let content: String
}

enum APIError: Error {
    case networkError
    case notFound
    case decodingError
    case serverError
}

// MARK: - Legacy API (콜백 기반)

class LegacyAPIClient {
    
    // Mock 데이터베이스
    private let mockUsers: [String: User] = [
        "user1": User(id: "user1", name: "김철수", email: "kim@example.com", isActive: true),
        "user2": User(id: "user2", name: "이영희", email: "lee@example.com", isActive: true),
        "user3": User(id: "user3", name: "박민수", email: "park@example.com", isActive: false)
    ]
    
    private let mockPosts: [Post] = [
        Post(id: "post1", userId: "user1", title: "첫 번째 포스트", content: "안녕하세요"),
        Post(id: "post2", userId: "user1", title: "두 번째 포스트", content: "반갑습니다"),
        Post(id: "post3", userId: "user2", title: "영희의 포스트", content: "Hello")
    ]
    
    // 1. 단일 사용자 조회 (콜백)
    func fetchUser(
        userId: String,
        completion: @escaping (Result<User, APIError>) -> Void
    ) {
        // 네트워크 지연 시뮬레이션
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else {
                completion(.failure(.networkError))
                return
            }
            
            if let user = self.mockUsers[userId] {
                completion(.success(user))
            } else {
                completion(.failure(.notFound))
            }
        }
    }
    
    // 2. 사용자의 포스트 조회 (콜백)
//    func fetchPosts(
//        userId: String,
//        completion: @escaping (Result<[Post], APIError>) -> Void
//    ) {
//        DispatchQueue.global().asyncAfter(deadline: .now() + 0.6) { [weak self] in
//            guard let self = self else {
//                completion(.failure(.networkError))
//                return
//            }
//            
//            let posts = self.mockPosts.filter { $0.userId == userId }
//            completion(.success(posts))
//        }
//    }
    
    func fetchUser(userId: String) async throws -> User {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) { [weak self] in
                guard let self else {
                    continuation.resume(throwing: APIError.networkError)
                    return
                }
                
                if let user = self.mockUsers[userId] {
                    continuation.resume(with: .success(user))
                } else {
                    continuation.resume(with: .failure(APIError.notFound))
                }
            }
        }
    }
    
    func fetchPosts(userId: String) async throws -> [Post] {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.6) { [weak self] in
                guard let self else {
                    continuation.resume(throwing: APIError.networkError)
                    return
                }
                let posts = self.mockPosts.filter { $0.userId == userId }
                continuation.resume(with: .success(posts))
            }
        }
    }
    
    // 4. 콜백 지옥 예제: 사용자 정보 + 포스트를 순차적으로 조회
//    func fetchUserWithPosts(
//        userId: String,
//        completion: @escaping (Result<(User, [Post]), APIError>) -> Void
//    ) {
//        // 첫 번째 콜백
//        fetchUser(userId: userId) { [weak self] userResult in
//            switch userResult {
//            case .success(let user):
//                // 두 번째 콜백 (중첩!)
//                self?.fetchPosts(userId: userId) { postsResult in
//                    switch postsResult {
//                    case .success(let posts):
//                        completion(.success((user, posts)))
//                    case .failure(let error):
//                        completion(.failure(error))
//                    }
//                }
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
//    }
    
    // 정답코드
    func fetchUserWithPosts(userId: String) async throws -> (User, [Post]) {
        let user = try await fetchUser(userId: userId)
        let posts = try await fetchPosts(userId: userId)
        return (user, posts)
    }
    
    // 병렬처리로 더 좋은 코드
//    func fetchUserWithPostsWithParallel(userId: String) async throws -> (User, [Post]) {
//        async let user = fetchUser(userId: userId)
//        async let posts = fetchPosts(userId: userId)
//        return try await (user, posts)
//    }
    
    
    // MARK: - 과제 2: 콜백 지옥을 async/await으로 개선

    /*
     TODO: fetchUserWithPosts를 async/await으로 변환하세요
     
     힌트:
     - 먼저 fetchUser와 fetchPosts를 각각 async 버전으로 만들기
     - 순차적으로 await 사용
     - switch 문 제거하고 간결하게
     
     func fetchUserWithPosts(userId: String) async throws -> (User, [Post]) {
         // 여기에 구현
     }
    */
}

// MARK: - 과제 1: 단일 메서드를 async/await으로 변환

/*
 TODO: fetchUser를 async/await으로 변환하세요
 
 힌트:
 - withCheckedThrowingContinuation 사용
 - Result 타입을 continuation.resume(with:)로 전달
 
 func fetchUser(userId: String) async throws -> User {
     // 여기에 구현
 }
*/

// MARK: - 과제 2: 콜백 지옥을 async/await으로 개선

/*
 TODO: fetchUserWithPosts를 async/await으로 변환하세요
 
 힌트:
 - 먼저 fetchUser와 fetchPosts를 각각 async 버전으로 만들기
 - 순차적으로 await 사용
 - switch 문 제거하고 간결하게
 
 func fetchUserWithPosts(userId: String) async throws -> (User, [Post]) {
     // 여기에 구현
 }
*/

// MARK: - 테스트 코드

print("=== 레거시 콜백 방식 테스트 ===\n")

//let legacyClient = LegacyAPIClient()
//
//// 레거시 방식
//legacyClient.fetchUser(userId: "user1") { result in
//    switch result {
//    case .success(let user):
//        print("✅ 콜백: \(user.name) (\(user.email))")
//    case .failure(let error):
//        print("❌ 에러: \(error)")
//    }
//}
//
//// 콜백 지옥 예제
//legacyClient.fetchUserWithPosts(userId: "user1") { result in
//    switch result {
//    case .success(let (user, posts)):
//        print("✅ 콜백 지옥: \(user.name)의 포스트 \(posts.count)개")
//        posts.forEach { print("  - \($0.title)") }
//    case .failure(let error):
//        print("❌ 에러: \(error)")
//    }
//}

// TODO: 여기에 async/await 버전 테스트 추가
/*
Task {
    do {
        let user = try await modernClient.fetchUser(userId: "user1")
        print("\n✅ Async: \(user.name) (\(user.email))")
        
        let (user2, posts) = try await modernClient.fetchUserWithPosts(userId: "user1")
        print("✅ Async: \(user2.name)의 포스트 \(posts.count)개")
        posts.forEach { print("  - \($0.title)") }
    } catch {
        print("❌ 에러: \(error)")
    }
}
*/

// 3초 후 플레이그라운드 종료
//DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//    PlaygroundPage.current.finishExecution()
//}
