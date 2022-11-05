//
//  ExpandedView.swift
//  Qwiker
//
//  Created by Богдан Зыков on 28.10.2022.
//

import SwiftUI

struct ExpandedView<Content: View> : View{
    @State private var offset: CGFloat = 0
    let minHeight: CGFloat
    let maxHeight: CGFloat
    let content: (CGFloat, CGRect, Binding<CGFloat>) -> Content
    
    init(minHeight: CGFloat,
         maxHeight: CGFloat,
         @ViewBuilder content: @escaping (CGFloat, CGRect, Binding<CGFloat>) -> Content) {
        
        self.content = content
        self.minHeight = minHeight
        self.maxHeight = maxHeight
    }
    
    var body: some View{
        GeometryReader { proxy in
            ZStack(alignment: .top){
                content(minHeight, proxy.frame(in: .local), $offset)
                    .offset(y: proxy.frame(in: .local).height - minHeight)
                    .offset(y: offset)
                    .gesture(DragGesture()
                        .onChanged({ value in
                            onChange(value, proxyFrame: proxy.frame(in: .local))
                        })
                            .onEnded({ value in
                                onEnded(value, proxyFrame: proxy.frame(in: .local))
                            })
                    )
            }
            .ignoresSafeArea(.all, edges: .bottom)
        }
        .frame(maxHeight: maxHeight)
    }
}


extension ExpandedView{
    
    private func onChange(_ value: DragGesture.Value, proxyFrame: CGRect){
        withAnimation(.easeInOut) {
            if value.startLocation.y > proxyFrame.midX{
                if value.translation.height < 0 && offset > (-proxyFrame.height + minHeight){
                    offset = value.translation.height
                }
            }
            if value.startLocation.y < proxyFrame.midX{
                if value.translation.height > 0 && offset < 0{
                    offset = (-proxyFrame.height + minHeight) + value.translation.height
                }
            }
        }
    }
    
    private func onEnded(_ value: DragGesture.Value, proxyFrame: CGRect){
        withAnimation(.easeInOut) {
            if value.startLocation.y > proxyFrame.midX{
                if -value.translation.height > proxyFrame.minX{
                    offset = (-proxyFrame.height + minHeight)
                    return
                }
                offset = 0
            }
            
            if value.startLocation.y < proxyFrame.midX{
                if value.translation.height < proxyFrame.minX{
                    offset = (-proxyFrame.height + minHeight)
                    return
                }
                offset = 0
            }
        }
    }
}
