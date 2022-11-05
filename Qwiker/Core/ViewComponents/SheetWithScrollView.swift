//
//  SheetWithScrollView.swift
//  Qwiker
//
//  Created by Bogdan Zykov on 05.11.2022.
//

import SwiftUI

struct SheetWithScrollView <Content: View>: View{
    let content: Content
    var spacing: CGFloat
    
    init(spacing: CGFloat = 15,
         @ViewBuilder content: @escaping () -> Content ){
        
        self.content = content()
        self.spacing = spacing
    }
    
    var body: some View {
        VStack(spacing: 15) {
            Capsule()
                .fill(Color.secondary.opacity(0.2))
                .frame(width: 50, height: 6)
                .padding(.top, 6)
            ScrollView(.vertical, showsIndicators: false){
                VStack(spacing: spacing) {
                    content
                }
                .padding(.horizontal)
            }
        }
        .hCenter()
        .background(Color.primaryBg)
        .clipShape(CustomCorners(corners: [.topLeft, .topRight], radius: 12))
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 0)
        .onAppear{
            UIScrollView.appearance().bounces = false
        }
        .onDisappear{
            UIScrollView.appearance().bounces = true
        }
    }
}
