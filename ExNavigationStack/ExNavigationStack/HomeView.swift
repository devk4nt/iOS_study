//
//  HomeView.swift
//  ExNavigationStack
//
//  Created by Kant on 10/27/25.
//

import SwiftUI

struct HomeView: View {
    @State private var path: [Route] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 20) {
                Button("쇼핑하기") {
                    path.append(.categoryList)
                }
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .categoryList:
                    CategoryListView(path: $path)
                case .itemList(let category):
                    ItemListView(category: category, path: $path)
                case .itemDetail(let id):
                    ItemDetailView(itemID: id)
                }
            }
            .onChange(of: path) { _, newValue in
                printNavigationLog(newValue)
            }
        }
    }
    
    private func printNavigationLog(_ stack: [Route]) {
        print("📚 Navigation Stack 변경됨:")
        if stack.isEmpty {
            print("⭐ 스택이 비었습니다 (모두 pop됨)")
        } else {
            for (index, route) in stack.enumerated() {
                switch route {
                case .categoryList:
                    print("   [\(index)] → CategoryList")
                case .itemList(let category):
                    print("   [\(index)] → ItemList(\(category))")
                case .itemDetail(let id):
                    print("   [\(index)] → ItemDetail(\(id))")
                }
            }
        }
        print("---------------------------")
    }
}
