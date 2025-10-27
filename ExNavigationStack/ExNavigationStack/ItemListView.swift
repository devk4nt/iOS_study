//
//  ItemListView.swift
//  ExNavigationStack
//
//  Created by Kant on 10/27/25.
//

import SwiftUI

struct ItemListView: View {
    let category: String
    @Binding var path: [Route]
    
    var body: some View {
        List(1..<6) { id in
            Button("🔹 \(category) \(id)") {
                path.append(.itemDetail(id: id))
            }
        }
        .navigationTitle("\(category)")
        .onAppear { print("✅ ItemListView(\(category)) 진입") }
        .onDisappear { print("👋 ItemListView(\(category)) 사라짐") }
    }
}
