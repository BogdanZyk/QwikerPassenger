//
//  BottomSheetView.swift
//  Qwiker
//
//  Created by Богдан Зыков on 31.10.2022.
//

import SwiftUI


struct BottomSheetView <Content: View>: View{
    let content: Content
    var spacing: CGFloat
    var maxHeightForBounds: Double
    
    init(spacing: CGFloat = 15,
         maxHeightForBounds: Double = 2.0,
         @ViewBuilder content: @escaping () -> Content ){
        
        self.content = content()
        self.maxHeightForBounds = maxHeightForBounds
        self.spacing = spacing
    }
    
    var body: some View {
        VStack(spacing: spacing) {
            content
        }
        .padding()
        .padding(.bottom, 50)
        .hCenter()
        .background(Color.white)
        .clipShape(CustomCorners(corners: [.topLeft, .topRight], radius: 12))
        .frame(maxHeight: getRect().height / maxHeightForBounds)
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 0)
    }
}
