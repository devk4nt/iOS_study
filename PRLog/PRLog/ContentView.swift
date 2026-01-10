//
//  ContentView.swift
//  PRLog
//
//  Created by Kant on 1/10/26.
//

import Foundation
import SwiftData

// MARK: - 운동 종목
@Model
final class Exercise {
    var id: UUID
    var name: String
    var category: ExerciseCategory
    var createdAt: Date
    
    @Relationship(deleteRule: .cascade, inverse: \ExerciseSet.exercise)
    var sets: [ExerciseSet] = []
    
    init(name: String, category: ExerciseCategory) {
        self.id = UUID()
        self.name = name
        self.category = category
        self.createdAt = Date()
    }
}

enum ExerciseCategory: String, Codable, CaseIterable {
    case chest = "가슴"
    case back = "등"
    case shoulder = "어깨"
    case leg = "하체"
    case arm = "팔"
    case core = "코어"
}

// MARK: - 운동 세트 기록
@Model
final class ExerciseSet {
    var id: UUID
    var weight: Double      // kg
    var reps: Int           // 횟수
    var setNumber: Int
    var isCompleted: Bool
    var recordedAt: Date
    
    var exercise: Exercise?
    var workoutSession: WorkoutSession?
    
    init(weight: Double, reps: Int, setNumber: Int) {
        self.id = UUID()
        self.weight = weight
        self.reps = reps
        self.setNumber = setNumber
        self.isCompleted = false
        self.recordedAt = Date()
    }
    
    // 볼륨 계산 (무게 × 횟수)
    var volume: Double {
        weight * Double(reps)
    }
}

// MARK: - 운동 세션 (하루 운동)
@Model
final class WorkoutSession {
    var id: UUID
    var date: Date
    var duration: TimeInterval
    var notes: String?
    
    var routine: WorkoutRoutine?
    
    @Relationship(deleteRule: .cascade, inverse: \ExerciseSet.workoutSession)
    var sets: [ExerciseSet] = []
    
    init(routine: WorkoutRoutine? = nil) {
        self.id = UUID()
        self.date = Date()
        self.duration = 0
        self.routine = routine
    }
    
    // 총 볼륨
    var totalVolume: Double {
        sets.reduce(0) { $0 + $1.volume }
    }
}

// MARK: - 운동 루틴 (재사용 가능한 템플릿)
@Model
final class WorkoutRoutine {
    var id: UUID
    var name: String
    var exerciseTemplates: [ExerciseTemplate]
    var createdAt: Date
    var lastUsedAt: Date?
    
    @Relationship(deleteRule: .nullify, inverse: \WorkoutSession.routine)
    var sessions: [WorkoutSession] = []
    
    init(name: String, exerciseTemplates: [ExerciseTemplate] = []) {
        self.id = UUID()
        self.name = name
        self.exerciseTemplates = exerciseTemplates
        self.createdAt = Date()
    }
}

// 루틴 내 운동 템플릿 (Codable로 저장)
struct ExerciseTemplate: Codable, Identifiable, Hashable {
    var id: UUID
    var exerciseName: String
    var category: ExerciseCategory
    var targetSets: Int
    var targetReps: Int
    
    init(exerciseName: String, category: ExerciseCategory, targetSets: Int = 4, targetReps: Int = 12) {
        self.id = UUID()
        self.exerciseName = exerciseName
        self.category = category
        self.targetSets = targetSets
        self.targetReps = targetReps
    }
}

import Foundation
import SwiftData

@Observable
final class ProgressTracker {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // 특정 운동의 최근 기록과 비교
    func getProgressComparison(for exerciseName: String) -> ProgressResult? {
        let descriptor = FetchDescriptor<ExerciseSet>(
            predicate: #Predicate { $0.exercise?.name == exerciseName && $0.isCompleted },
            sortBy: [SortDescriptor(\.recordedAt, order: .reverse)]
        )
        
        guard let allSets = try? modelContext.fetch(descriptor),
              allSets.count >= 2 else { return nil }
        
        // 최근 세션과 이전 세션 비교
        let today = Calendar.current.startOfDay(for: Date())
        let recentSets = allSets.filter {
            Calendar.current.isDate($0.recordedAt, inSameDayAs: today)
        }
        let previousSets = allSets.filter {
            !Calendar.current.isDate($0.recordedAt, inSameDayAs: today)
        }
        
        guard !recentSets.isEmpty, !previousSets.isEmpty else { return nil }
        
        let recentMaxWeight = recentSets.map(\.weight).max() ?? 0
        let previousMaxWeight = previousSets.prefix(10).map(\.weight).max() ?? 0
        
        let recentTotalVolume = recentSets.reduce(0) { $0 + $1.volume }
        let previousTotalVolume = previousSets.prefix(10).reduce(0) { $0 + $1.volume }
        
        return ProgressResult(
            exerciseName: exerciseName,
            currentMaxWeight: recentMaxWeight,
            previousMaxWeight: previousMaxWeight,
            currentVolume: recentTotalVolume,
            previousVolume: previousTotalVolume
        )
    }
}

struct ProgressResult {
    let exerciseName: String
    let currentMaxWeight: Double
    let previousMaxWeight: Double
    let currentVolume: Double
    let previousVolume: Double
    
    var weightImprovement: Double {
        guard previousMaxWeight > 0 else { return 0 }
        return ((currentMaxWeight - previousMaxWeight) / previousMaxWeight) * 100
    }
    
    var volumeImprovement: Double {
        guard previousVolume > 0 else { return 0 }
        return ((currentVolume - previousVolume) / previousVolume) * 100
    }
    
    var hasImproved: Bool {
        weightImprovement > 0 || volumeImprovement > 0
    }
}

import SwiftUI

struct ProgressBadgeView: View {
    let progress: ProgressResult
    
    var body: some View {
        HStack(spacing: 16) {
            improvementCard(
                title: "최대 무게",
                current: "\(Int(progress.currentMaxWeight))kg",
                percentage: progress.weightImprovement
            )
            
            improvementCard(
                title: "총 볼륨",
                current: "\(Int(progress.currentVolume))",
                percentage: progress.volumeImprovement
            )
        }
    }
    
    @ViewBuilder
    private func improvementCard(title: String, current: String, percentage: Double) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text(current)
                .font(.title2)
                .fontWeight(.bold)
            
            HStack(spacing: 2) {
                Image(systemName: percentage >= 0 ? "arrow.up.right" : "arrow.down.right")
                Text("\(abs(percentage), specifier: "%.1f")%")
            }
            .font(.caption)
            .fontWeight(.medium)
            .foregroundStyle(percentage >= 0 ? .green : .red)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}
