//
//  CircleButtonWithTitle.swift
//  Qwiker
//
//  Created by Bogdan Zykov on 05.11.2022.
//

import SwiftUI

struct CircleButtonWithTitle: View {
    let title: String
    let imageName: String
    let action: () -> Void
    var body: some View{
        Button {
            action()
        } label: {
            VStack{
                Image(systemName: imageName)
                    .imageScale(.medium)
                    .foregroundColor(.black)
                    .frame(width: 50, height: 50)
                    .background{Circle()
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.2), radius: 5)
                    }
                Text(title)
                    .font(.poppinsRegular(size: 14))
                    .foregroundColor(.gray)
            }
        }
    }
}

struct CircleButtonWithTitle_Previews: PreviewProvider {
    static var previews: some View {
        CircleButtonWithTitle(title: "Tap", imageName: "xmark", action: {})
    }
}
