//
//  ThinLayer.swift
//  ExThinLayer
//
//  Created by Kant on 9/21/25.
//

import Combine
import Foundation

struct User: Codable {
    let id: String
    let name: String?
    let email: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
    }
}

/// 의존성의 방향 (상위에서 하위로만 의존)
/// ViewModel → UseCase → Repository(Protocol) → Repository 구현체(Remote/Local 등)

/// 1. Domain Layer - 추상화된 얇은 레이어
protocol UserRepository {
    func fetchUser(id: String) async throws -> User
}


/// 2. Data Layer - 실제 구현체
final class RemoteUserRepository: UserRepository {
    func fetchUser(id: String) async throws -> User {
        let url = URL(string: "https://api.example.com/users/\(id)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(User.self, from: data)
    }
}

/// 3. UseCase Layer (얇은 레이어를 통해 기능 확장)
final class FetchUserUseCase {
    private let repository: UserRepository
    
    init(repository: UserRepository) {
        self.repository = repository
    }
    
    func execute(id: String) async throws -> User {
        return try await repository.fetchUser(id: id)
    }
}

/// 4. ViewModel Layer
@MainActor
final class UserViewModel: ObservableObject {
    @Published var user: User?
    private let fetchUserUseCase: FetchUserUseCase
    
    init(fetchUserUseCase: FetchUserUseCase) {
        self.fetchUserUseCase = fetchUserUseCase
    }
    
    func loadUser(id: String) async {
        do {
            self.user = try await fetchUserUseCase.execute(id: id)
        } catch {
            print("Error loading user: \(error)")
        }
    }
}
