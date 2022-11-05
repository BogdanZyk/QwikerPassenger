//
//  CurrentPaymentMethodCellView.swift
//  Qwiker
//
//  Created by Bogdan Zykov on 05.11.2022.
//

import SwiftUI

struct CurrentPaymentMethodCellView: View{
    var body: some View{
        VStack {
            Button {
                
            } label: {
                HStack(spacing: 20){
                    Image("cash-icon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                    VStack(alignment: .leading, spacing: 2){
                        Text("Cash")
                            .foregroundColor(.black)
                            .font(.poppinsMedium(size: 16))
                        Text("Change Payment method")
                            .font(.poppinsRegular(size: 12))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .imageScale(.small)
                        .foregroundColor(.gray)
                }
            }
            .padding(.bottom, 5)
            Divider()
        }
    }
}

struct CurrentPaymentMethodCellView_Previews: PreviewProvider {
    static var previews: some View {
        CurrentPaymentMethodCellView()
    }
}
