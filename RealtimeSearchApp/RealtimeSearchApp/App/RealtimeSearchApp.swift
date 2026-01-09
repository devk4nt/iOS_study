//
//  RealtimeSearchAppApp.swift
//  RealtimeSearchApp
//
//  Created by Kant on 12/24/25.
//

import SwiftUI

@main
struct RealtimeSearchAppApp: App {
    var body: some Scene {
        WindowGroup {
            SearchView(
                viewModel: SearchViewModel(
                    searchService: MockSearchService()
                )
            )
        }
    }
}
