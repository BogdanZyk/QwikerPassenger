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
    let action: () -> Void
    var body: some View {
        Button {
            action()
        } label: {
            Text(title)
                .font(.poppinsMedium(size: 20))
                .foregroundColor(.white)
                .frame(height: 50)
                .hCenter()
                .background(Color.primaryBlue)
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
