//
//  JumpingDraggIcon.swift
//  Qwiker
//
//  Created by Богдан Зыков on 28.10.2022.
//

import SwiftUI

struct JumpingDraggIcon: View{
    let isExpand: Bool
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    @State private var runCount = 0
    @State private var changeOffset: CGFloat = 0
    var body: some View{
        Capsule()
            .fill(Color(.systemGray2))
            .frame(width: 40, height: 5)
            .offset(y: changeOffset)
            .onReceive(timer, perform: { time in
                if !isExpand{
                    runCount += 1
                    withAnimation {
                        changeOffset += runCount % 2 == 0 ? 5 : -5
                    }
                }
            })
    }
}

struct JumpingDraggIcon_Previews: PreviewProvider {
    static var previews: some View {
        JumpingDraggIcon(isExpand: true)
    }
}
