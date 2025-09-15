//
//  ContentView.swift
//  StickyHeaderList
//
//  Created by Kant on 9/15/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        CustomList { progress in
            
        } topContent: { progress, safeAreaTop in
            
        } header: { progress in
            
        } content: {
            
        }
    }
    
    /// Top Hero Image
    @ViewBuilder
    func HeroImage(_ progress: CGFloat, _ safeAreaTop: CGFloat) -> some View {
        GeometryReader {
            let minY = $0.frame(in: .global).minY - safeAreaTop
            let size = $0.size
            let height = size.height + (minY > 0 ? minY : 0)
            
            Image(.airplane)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size.width, height: height)
        }
        .frame(height: 250)
    }
    
    /// Custom Header View
    @ViewBuilder
    func HeaderView(_ progress: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Apple Foods")
                .font(.title2.bold())
                .frame(height: 35)
            
            HStack(spacing: 6) {
                Image(systemName: "star.fill")
                    .font(.caption)
                
                Text("4.5 **(20K ratings)**")
                    .font(.callout)
                
                Image(systemName: "clock")
                    .font(.system(size: 15, weight: .semibold))
                    .padding(.leading, 10)
                
                Text("35-40 **Mins**")
                    .font(.callout)
            }
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
    
    }
}

#Preview {
    ContentView()
}
