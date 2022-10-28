//
//  PrimaryButtonView.swift
//  Qwiker
//
//  Created by Богдан Зыков on 27.10.2022.
//

import SwiftUI

struct PrimaryButtonView: View {
    var showLoader: Bool = false
    let title: String
    var font: Font = .poppinsMedium(size: 20)
    var bgColor: Color = .primaryBlue
    var fontColor: Color = .white
    var isBackground: Bool = true
    var border: Bool = false
    let action: () -> Void
    var body: some View {
        Button {
            action()
        } label: {
            Text(title)
                .font(font)
                .foregroundColor(fontColor)
                .frame(height: 50)
                .hCenter()
                .background(isBackground ? bgColor : Color.clear)
                .background{
                    if border{
                        RoundedRectangle(cornerRadius: 5).stroke(lineWidth: 1.5)
                            .fill(bgColor)
                    }
                }
                .cornerRadius(5)
                .opacity(showLoader ? 0 : 1)
                .overlay{
                    if showLoader{
                        ProgressView()
                    }
                }
        }

    }
}

struct PrimaryButtonView_Previews: PreviewProvider {
    static var previews: some View {
        PrimaryButtonView( title: "next"){}
    }
}
