//
//  SearchResult.swift
//  RealtimeSearchApp
//
//  Created by Kant on 12/24/25.
//

import Foundation

/// 검색 결과를 나타내는 모델
/// Sendable: Swift 6 에서 actor 간 안전한 데이터 전달을 보장
/// Identifiable: SwiftUI List 에서 각 항목을 고유하게 식별
/// Hashable: Set, Dictionary 키로 사용 가능
struct SearchResult: Identifiable, Sendable, Hashable {
    let id: UUID
    let title: String
    let subtitle: String
    let category: Category
    let timestamp: Date
    
    enum Category: String, Sendable, CaseIterable {
        case article = "Article"
        case video = "Video"
        case podcast = "Podcast"
        case code = "Code"
        
        var icon: String {
            switch self {
            case .article: return "doc.text"
            case .video: return "play.rectangle"
            case .podcast: return "mic"
            case .code: return "chevron.left.forwardslash.chevron.right"
            }
        }
    }
    
    /// 테스트 및 Preview용 샘플 데이터
    static let samples: [SearchResult] = [
        SearchResult(
            id: UUID(),
            title: "Swift 6 Migration Guide",
            subtitle: "Complete guide to migrating your codebase",
            category: .article,
            timestamp: Date()
        ),
        SearchResult(
            id: UUID(),
            title: "WWDC24: What's new in Swift",
            subtitle: "60 minutes of new Swift features",
            category: .video,
            timestamp: Date().addingTimeInterval(-3600)
        ),
        SearchResult(
            id: UUID(),
            title: "SwiftUI Concurrency Patterns",
            subtitle: "Best practices for async/await in SwiftUI",
            category: .podcast,
            timestamp: Date().addingTimeInterval(-7200)
        ),
        SearchResult(
            id: UUID(),
            title: "Async/Await Deep Dive",
            subtitle: "Understanding structured concurrency",
            category: .code,
            timestamp: Date().addingTimeInterval(-10800)
        )
    ]
}
