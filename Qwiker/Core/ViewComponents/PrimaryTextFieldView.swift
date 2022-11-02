//
//  PrimaryTextFieldView.swift
//  Qwiker
//
//  Created by Богдан Зыков on 27.10.2022.
//

import SwiftUI

struct PrimaryTextFieldView: View {
    let label: String
    @Binding var text: String
    var body: some View {
        TextField(text: $text) {
            Text(label)
                .foregroundColor(.secondaryGrey)
        }
        .padding(.horizontal)
        .frame(height: 50)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 5))
        .background(Color.secondaryGrey, in: RoundedRectangle(cornerRadius: 5).stroke(lineWidth: 1.5))
        .font(.poppinsRegular(size: 18))
    }
}

struct PrimaryTextFieldView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            
            PrimaryTextFieldView(label: "label", text: .constant(""))
                .padding()
        }
    }
}
