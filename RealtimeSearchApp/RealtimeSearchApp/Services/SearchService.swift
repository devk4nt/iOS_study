//
//  SearchService.swift
//  RealtimeSearchApp
//
//  Created by Kant on 12/24/25.
//

import Foundation

/// 검색 서비스 프로토콜
/// - Sendable: actor 경계를 넘어 안전하게 전달 가능
/// - AnyActor: 어떤 actor에서든 호출 가능
protocol SearchServiceProtocol: Sendable {
    /// 검색어로 검색 수행
    /// - Parameter query: 검색어
    /// - Returns: 검색 결과 배열
    /// - Throws: 네트워크 또는 파싱 오류
    func search(_ query: String) async throws -> [SearchResult]
}

/// 검색 관련 에러 정의
/// Swift 6의 Typed throws를 위한 에러 타입
enum SearchError: Error, Sendable, LocalizedError {
    case invalidQuery
    case networkError(underlying: Error)
    case decodingError
    case cancelled
    
    var errorDescription: String? {
        switch self {
        case .invalidQuery:
            return "검색어가 유효하지 않습니다."
        case .networkError(let error):
            return "네트워크 오류: \(error.localizedDescription)"
        case .decodingError:
            return "데이터 처리 중 오류가 발생했습니다."
        case .cancelled:
            return "검색이 취소되었습니다."
        }
    }
}
