import UIKit
import Foundation
import Combine

// #1
// Task.sleep 은 스레드를 점유하지 않고 현재 Task 만 suspend
// → 같은 스레드로 다른 Task 가 실행될 수 있다.
Task {
    for i in 1...5 {
        print("Tick")
        try? await Task.sleep(nanoseconds: 1_000_000_000)
    }
}

// #2
// 콜백 기반 함수(가정)
func fetchMessage(completion: @escaping (String) -> Void) {
    DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
        completion("Hello from callback!")
    }
}


func fetchMessage() async -> String {
    await withCheckedContinuation { continuation in
        fetchMessage { text in
            continuation.resume(returning: text)
        }
    }
}

Task {
    let text = await fetchMessage()
    print("#2: \(text)")
}

// #3
//let publisher = NotificationCenter.default.publisher(for: .init("MyEvent"))
//NotificationCenter.addObserver(.Publisher(center: .default, name: "MyEvent"))


// #6
@MainActor
func updateUI() {
    
}

Task {
    // MainActor 컨텍스트로 전환하여 안전하게 호출하는 모습
    await MainActor.run {
        updateUI()
    }
}

// #7
/**
 Just("Swift")를 시작으로,
 •    flatMap에서 Future를 이용해 1초 뒤 "Swift Concurrency"라는 문자열을 반환하는 Publisher를 연결하라.
 •    sink로 결과를 출력하라.
 */

var bag = Set<AnyCancellable>()

//Just("Swift")
//    .flatMap { _ in
//        defer {
//            Future<String, Never> { promise in
//                Task {
//                    try? await Task.sleep(nanoseconds: 1_000_000_000)
//                    promise(.success("Swift Concurrency"))
//                }
//            }
//        }
////        Future { promise in
////            promise(.success("Swift Concurrency"))
////        }
//    }
//    .sink { completion in
//        print("completion:\(completion)")
//    }
//    .store(in: &bag)
////    .sink { "" in
////        
////    }

Just("Swift")
    // Just는 Never 실패 → Future도 Failure를 Never로 맞추면 깔끔
    .flatMap { _ in
        Deferred {
            Future<String, Never> { promise in
                Task {
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                    promise(.success("Swift Concurrency"))
                }
            }
        }
    }
    .sink(receiveCompletion: { completion in
        print("completion:", completion)
    }, receiveValue: { value in
        print("✅ #7:", value)
    })
    .store(in: &bag)
