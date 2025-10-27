//
//  ContentView.swift
//  ExCustomTollBottomBar
//
//  Created by Kant on 9/19/25.
//

import SwiftUI

struct ContentView: View {
    /// For knowing whether the stack is at the root view or not!
    @State private var path: NavigationPath = .init()
    @State private var searchText: String = ""
    @FocusState private var isKeyboardActive: Bool
    
    var body: some View {
        NavigationStack(path: $path) {
            /// Dummy List View
            List {
                ForEach(1...50, id: \.self) { index in
                    NavigationLink(value: "iCloud+ Subscription") {
                        Text("iCloud+ Subscription \(index)")
                    }
                }
            }
            .navigationTitle("Inbox")
            .navigationSubtitle("Last Updated - Just Now")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Options", systemImage: "ellipsis") {
                        
                    }
                }
            }
            /// Since safeAreaBar is attached to the Entire Navigation Stack, it won't push content inside of it's content, and since the max size of the bottom bar will be anyway 50, so add a safe Area bottom padding to each navigation view to resolve this issue!
            .safeAreaPadding(.bottom, 50)
            .navigationDestination(for: String.self) { value in
                Text("Full-Email View")
                    .navigationTitle(value)
            }
        }
        .safeAreaBar(edge: .bottom, spacing: 0) {
            /// Empty View don't have the soft blur effects!
            Text(".")
                .frame(height: 50)
        }
        .overlay(alignment: .bottom) {
            CustomBottomBar(
                path: $path,
                searchText: $searchText,
                isKeyboardActive: $isKeyboardActive) { isExpanded in
                    Group {
                        ZStack {
                            Image(systemName: "line.3.horizontal.decrease")
                                .blurFade(!isExpanded)
                            Image(systemName: "trash")
                                .blurFade(isExpanded)
                        }
                        Group {
                            Image(systemName: "folder")
                            Image(systemName: "arrowshape.turn.up.forward.fill")
                        }
                        .opacity(1.0)
                        //.blurFade(isExpanded) // TODO: - 이렇게 추적하고 있는 중이였음
                    }
                    .font(.title2)
                    
                } mainAction: {
                    Image(systemName: isKeyboardActive ? "xmark" : "square.and.pencil")
                        .font(.title2)
                        .contentTransition(.symbolEffect)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .contentShape(.circle)
                        .onTapGesture {
                            if isKeyboardActive {
                                isKeyboardActive = false
                            } else {
                                print("Write")
                            }
                        }
                }
        }
    }
}

struct CustomBottomBar<LeadingContent: View, MainAction: View>: View {
    @Binding var path: NavigationPath
    @Binding var searchText: String
    var isKeyboardActive: FocusState<Bool>.Binding
    @ViewBuilder var leadingContent: (_ isExpanded: Bool) -> LeadingContent
    @ViewBuilder var mainAction: MainAction
    @State private var bounce: CGFloat = 0
    
    var body: some View {
//        GlassEffectContainer(spacing: 10) {
//            
//        }
        HStack(spacing: 10) {
            /// Hiding it when keyboard is expanded!
            Circle()
                .foregroundStyle(.green)
                .frame(width:50, height: 50)
                .overlay(alignment: .leading) {
//                    let layout = isExpanded ? AnyLayout(HStackLayout(spacing: 10)) : AnyLayout(ZStackLayout())
//                    
//                    layout {
//                        
//                    }
                    HStack(spacing: 10) {
                        ForEach(subviews: leadingContent(isExpanded)) { subview in
                            subview
                                .frame(width: 50, height: 50)
                        }
                    }
                    /// Start
                    .blurFade(!isKeyboardActive.wrappedValue)
                    .modifier(ScaleModifier(bounce: bounce))
                }
                .zIndex(1000)
                .transition(.blurReplace)
                .blurFade(!isKeyboardActive.wrappedValue)
            
            /// Search Bar
            GeometryReader {
                let size = $0.size
                /// Scaling the search bar to hide behind the leading content!
                /// Since 50 is the minimum width!
                let scale = 50 / size.width
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    
                    TextField("Search", text: $searchText)
                        .submitLabel(.search)
                        .focused(isKeyboardActive)
                    
                    Image(systemName: "mic.fill")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 15)
                .frame(width: size.width, height: size.height)
                .geometryGroup()
                /// Start
                .blurFade(!isExpanded)
                .scaleEffect(isExpanded ? scale : 1, anchor: .topLeading)
                /// End
                .glassEffect(.regular.interactive(), in: .capsule)
                .blurFade(!isExpanded)
                .scaleEffect(isExpanded ? scale : 1, anchor: .leading)
                .offset(x: isExpanded ? -50 : 0)
            }
            .frame(height: 50)
            /// 50 Width, 10 Spacing!
            .padding(.leading, isKeyboardActive.wrappedValue ? -60 : 0)
            /// Disabling Interaction when expanded
            .disabled(isExpanded)
            
            /// Main Action View
            /// Which always stays in any screen!
            mainAction
                .frame(width: 50, height: 50)
                .glassEffect(.regular.interactive(), in: .circle)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, isKeyboardActive.wrappedValue ? 15 : 0)
        .animation(.smooth(duration: 0.3, extraBounce: 0), value: isKeyboardActive.wrappedValue)
        .animation(.bouncy, value: isExpanded)
        .onChange(of: isExpanded) { oldValue, newValue in
            withAnimation(.bouncy) {
                bounce += 1
            }
        }
    }
    
    var isExpanded: Bool {
        !path.isEmpty
    }
}

extension View {
    /// Blur Fade In / Out
    @ViewBuilder
    func blurFade(_ status: Bool) -> some View {
        self
            .blur(radius: status ? 0 : 5)
            .opacity(status ? 1: 0)
    }
}

struct ScaleModifier: ViewModifier, Animatable {
    var bounce: CGFloat
    var animatableData: CGFloat {
        get { bounce }
        set { bounce = newValue }
    }
    
    func body(content: Content) -> some View {
        content
            .compositingGroup()
            .blur(radius: loopProgress * 5)
            /// Start
            .offset(x: loopProgress * 15, y: loopProgress * 8)
            .glassEffect(.regular.interactive(), in: .capsule)
            .scaleEffect(1 + (loopProgress * 0.38), anchor: .center)
    }
    
    /// Returns a progress from  0 - 1 and back from 1 - 0 every time the bounce is incremented!
    var loopProgress: CGFloat {
        let moddedBounce = bounce.truncatingRemainder(dividingBy: 1)
        let value = moddedBounce > 0.5 ? 1 - moddedBounce : moddedBounce
        return value * 2
    }
}

#Preview {
    ContentView()
}
