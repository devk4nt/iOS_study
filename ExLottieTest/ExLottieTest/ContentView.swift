//
//  ContentView.swift
//  ExLottieTest
//
//  Created by Kant on 8/1/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Lottie Performance Test")
                .font(.headline)
                .padding()
            
            LottieView(animationName: "character_anim")
                .frame(width: 200, height: 200)
        }
    }
}

#Preview {
    ContentView()
}
