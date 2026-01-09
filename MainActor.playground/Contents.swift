//
//  MainActorVsDispatchQueue.swift
//
//  이 파일은 블로그 글의 흐름(개념 → 한계 → 보장 → 해결 패턴)을
//  “코드 + 주석”으로 그대로 따라가며 정리한 예시입니다.
//
//  - MainActor = "메인 스레드에서 실행" 그 자체가 아니라
//               "UI와 결합된 공유 상태를 안전하게 다루기 위한 격리(접근 규칙)"를 의미
//  - DispatchQueue.main.async = "언제 실행할지(스케줄링)"만 제어
//  - MainActor = "누가/어디서 접근해도 되는지(격리 규칙)"를 타입/함수 수준에서 표현 + 컴파일 타임 강제
//

import Foundation
import UIKit

// MARK: - 0) 준비: 화면 예시용 UILabel (Playground / 샘플 앱에서 사용)
final class DemoViewController: UIViewController {
    private let label = UILabel()
    private let button = UIButton(type: .system)

    private let vm = CounterViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        label.textAlignment = .center
        label.text = "state: 0"
        label.translatesAutoresizingMaskIntoConstraints = false

        button.setTitle("Run Demo", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(runDemo), for: .touchUpInside)

        view.addSubview(label)
        view.addSubview(button)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 16)
        ])
    }

    @objc private func runDemo() {
        runMainActorHopExample(label: label)
        runDispatchQueueLimitationsExample(label: label)
        runMainActorGuaranteeExample(label: label, viewModel: vm)
        runSafePatternsExamples(label: label, viewModel: vm)
    }
}

// MARK: - 1) “메인 스레드에서 실행”이 아니라 “MainActor 격리”를 보여주는 최소 예시

/// ✅ 이 함수는 "메인 스레드에서 실행"이라기보다
///    "MainActor 격리 규칙을 따르는 함수"라고 선언하는 것.
///
/// - 의미:
///   - UI 업데이트처럼 “MainActor 소유 상태(= UI 관련 공유 상태)”를 안전하게 다루기 위해
///     이 함수는 MainActor 컨텍스트에서 실행되어야 한다.
@MainActor
func updateUI(label: UILabel, text: String) {
    label.text = text
}

/// ✅ detached(어떤 Actor에도 속하지 않음)에서 호출해도,
///    `await`를 통해 MainActor로 "hop(전환)"하며 안전하게 호출 가능.
func runMainActorHopExample(label: UILabel) {
    Task.detached {
        // detached는 MainActor 보장이 없음
        // 하지만 updateUI는 @MainActor 격리이므로
        // 호출할 때 await를 통해 MainActor로 hop 하게 됨.
        await updateUI(label: label, text: "Hop to MainActor ✅")
    }
}

// MARK: - 2) DispatchQueue.main.async의 한계: "언제 실행"만 제어하고 "무엇을 접근"은 못 막음

/// DispatchQueue 기반 ViewModel 예시.
/// - 이 타입은 "어디서 state를 접근해야 하는지" 규칙이 타입에 남지 않는다.
/// - 그래서 호출하는 쪽이 실수하기 쉽고, 컴파일러가 막아주지 못한다.
final class LegacyViewModel {
    var state: Int = 0
}

/// ❗ DispatchQueue.main.async는 UI를 메인에서 실행시키는 데는 도움되지만,
///    공유 상태(state)에 대한 접근 규칙을 컴파일 타임에 강제할 수 없다.
///    (data race 가능성은 구조적으로 남음)
func runDispatchQueueLimitationsExample(label: UILabel) {
    let vm = LegacyViewModel()

    // 여러 백그라운드 작업이 동시에 state에 접근한다고 가정
    DispatchQueue.global(qos: .userInitiated).async {
        vm.state += 1 // 컴파일러는 안전성 판단 불가 (규칙이 타입에 없음)

        DispatchQueue.main.async {
            label.text = "Legacy state: \(vm.state) (Queue ✅ / Rule ❌)"
        }
    }

    DispatchQueue.global(qos: .userInitiated).async {
        vm.state += 1 // 경쟁 조건 가능

        DispatchQueue.main.async {
            label.text = "Legacy state: \(vm.state) (Race possible ⚠️)"
        }
    }
}

// MARK: - 3) MainActor가 제공하는 보장: 컴파일 타임 격리 규칙 + 구조적 data race 차단

/// ✅ 타입 전체를 MainActor에 격리
/// - 의미:
///   - 이 타입의 상태(state)와 메서드는 MainActor에서만 접근 가능
///   - UI와 결합된 공유 상태를 타입 레벨로 표현
@MainActor
final class CounterViewModel {
    private(set) var state: Int = 0

    func increment() {
        state += 1
    }

    func setState(_ newValue: Int) {
        state = newValue
    }
}

/// ❌ detached에서 직접 접근하면 컴파일러가 막는 지점을 “주석으로” 명확히 보여준다.
/// (실제로 주석 해제 시 컴파일 에러가 발생해야 정상)
func runMainActorGuaranteeExample(label: UILabel, viewModel: CounterViewModel) {
    Task.detached {
        // ❌ 컴파일 에러 예시 (주석 해제하면 에러가 나는 것이 의도)
        // viewModel.increment()
        // viewModel.setState(999)
        // viewModel.state += 1

        // ✅ 대신 MainActor로 hop 하면 OK
        await MainActor.run {
            viewModel.increment()
            label.text = "Actor state: \(viewModel.state) ✅ (compile-time rule)"
        }
    }
}

// MARK: - 4) detached에서 “오류 없이” 실행하는 3가지 패턴

/// 패턴 1) await MainActor.run { } 로 격리 영역 안에서 수행
func pattern1_MainActorRun(viewModel: CounterViewModel, label: UILabel) {
    Task.detached {
        await MainActor.run {
            viewModel.increment()
            label.text = "Pattern1 state: \(viewModel.state) ✅"
        }
    }
}

/// 패턴 2) Task { @MainActor in ... } 로 처음부터 MainActor에 붙여 실행
func pattern2_TaskMainActor(viewModel: CounterViewModel, label: UILabel) {
    Task { @MainActor in
        viewModel.increment()
        label.text = "Pattern2 state: \(viewModel.state) ✅"
    }
}

/// 패턴 3) 무거운 일은 밖에서 + UI/상태 반영만 MainActor에서
func pattern3_BackgroundWorkThenApply(viewModel: CounterViewModel, label: UILabel) {
    Task.detached {
        // 1) 백그라운드에서 무거운 작업
        let fetched = (0..<500_000).reduce(0, +)

        // 2) 결과 반영은 MainActor에서 (UI/상태 = 격리 규칙 준수)
        await MainActor.run {
            viewModel.setState(fetched % 100)
            label.text = "Pattern3 state: \(viewModel.state) ✅ (heavy work off-main)"
        }
    }
}

func runSafePatternsExamples(label: UILabel, viewModel: CounterViewModel) {
    pattern1_MainActorRun(viewModel: viewModel, label: label)
    pattern2_TaskMainActor(viewModel: viewModel, label: label)
    pattern3_BackgroundWorkThenApply(viewModel: viewModel, label: label)
}

// MARK: - 5) DispatchQueue vs MainActor 차이를 코드 구조로 “각인”시키는 비교

/// DispatchQueue 방식: "메인에서 실행"은 맞추지만, 접근 규칙이 타입에 남지 않음
final class QueueBasedVM {
    var state = 0

    func incrementFromAnywhere() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.state += 1
        }
    }
}

/// MainActor 방식: "이 상태는 MainActor 소유"가 타입에 남음
@MainActor
final class ActorBasedVM {
    var state = 0
    func increment() { state += 1 }
}

// MARK: - 6) 실행 진입점 (Playground / 앱 둘 다 사용 가능)

/// Playground라면 아래 함수를 호출해 DemoViewController를 띄우면 된다.
/// 앱이라면 SceneDelegate / AppDelegate에서 rootViewController로 설정하면 된다.
func makeDemoViewController() -> UIViewController {
    DemoViewController()
}

/*
 ======================================================================
 Apple Developer 문서(참고용)
 - Global actors / MainActor:
   https://developer.apple.com/documentation/swift/globalactor
 - Concurrency 개요:
   https://developer.apple.com/documentation/swift/concurrency
 ======================================================================
*/
