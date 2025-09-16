//
//  CustomList.swift
//  StickyHeaderList
//
//  Created by Kant on 9/15/25.
//

import SwiftUI

struct CustomList<NavBar: View, TopContent: View, Header: View, Content: View>: View {
    /// The NavBar allows us to place cutom titles and buttons at the top of the list view, which acts as a navigation bar.
    @ViewBuilder var navBar: (_ progress: CGFloat) -> NavBar
    /// The TopConetnt is essentially a stretchy view or can be a regular Hero Image/Content that needs to be displayed./
    @ViewBuilder var topContent: (_ progress: CGFloat, _ safeAreaTop: CGFloat) -> TopContent
    /// The Header is the conetnt that should be stricky at the top when we scroll.
    @ViewBuilder var header: (_ progress: CGFloat) -> Header
    /// The Content allows us to place list content.
    @ViewBuilder var content: Content
    
    /// View Properties
    @State private var headerProgress: CGFloat = 0
    @State private var safeAreaTop: CGFloat = 0
    @State private var topContentHeight: CGFloat = 0
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        List {
            topContent(headerProgress, safeAreaTop)
                .onGeometryChange(
                    for: CGFloat.self,
                    of: { $0.size.height },
                    action: { newValue in
                    topContentHeight = newValue
                })
                .customListRow()
            Section {
                content
            } header: {
                header(headerProgress)
                    .foregroundStyle(foregroundColor)
                    .onGeometryChange(
                        for: CGFloat.self,
                        of: { $0.frame(in: .named("LISTVIEW")).minY },
                        action: { newValue in
                        guard topContentHeight == .zero else { return }
                        let progress = (newValue - safeAreaTop) / topContentHeight
                        let cappedProgress = max(min(progress, 1), 0)
                        self.headerProgress = cappedProgress
                        print(#fileID, #function, #line, "🐧 cappedProgress:\(cappedProgress)")
                    })
                    .customListRow()
            }
        }
        .listStyle(.plain)
        .listRowSpacing(0)
        .listSectionSpacing(0)
        .overlay(alignment: .top) {
            navBar(headerProgress)
        }
        .coordinateSpace(.named("LISTVIEW"))
        .onGeometryChange(for: CGFloat.self) {
            $0.safeAreaInsets.top
        } action: { newValue in
            safeAreaTop = newValue
        }
    }
    
    var foregroundColor: Color {
        colorScheme == .dark ? .white : .black
    }
}

extension View {
    @ViewBuilder
    func customListRow(top: CGFloat = 0, bottom: CGFloat = 0) -> some View {
        self.listRowInsets(.init(top: top, leading: 0, bottom: bottom, trailing: 0))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
    }
}

#Preview {
    ContentView()
}
