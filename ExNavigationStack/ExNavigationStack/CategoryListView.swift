//
//  CategoryListView.swift
//  ExNavigationStack
//
//  Created by Kant on 10/27/25.
//

import SwiftUI

struct CategoryListView: View {
    @Binding var path: [Route]
    private let categories = ["Mac", "iPad", "iPhone", "Watch"]
    
    var body: some View {
        List(categories, id: \.self) { category in
            Button(action: {
                path.append(.itemList(category))
            }) {
                Label(category, systemImage: "folder")
            }
        }
        .navigationTitle("카테고리 목록")
        .onAppear { print("✅ CategoryListView 진입") }
        .onDisappear { print("👋 CategoryListView 사라짐") }
    }
}
