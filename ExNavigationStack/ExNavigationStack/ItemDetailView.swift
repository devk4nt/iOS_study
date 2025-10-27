//
//  ItemDetailView.swift
//  ExNavigationStack
//
//  Created by Kant on 10/27/25.
//

import SwiftUI

struct ItemDetailView: View {
    let itemID: Int
    
    var body: some View {
        VStack(spacing: 16) {
            Text("📄 \(itemID) 상세보기 화면")
                .font(.headline)
        }
        .navigationTitle("상세보기")
        .onAppear { print("✅ ItemDetailView(\(itemID)) 진입") }
        .onDisappear { print("👋 ItemDetailView(\(itemID)) 사라짐") }
    }
}
