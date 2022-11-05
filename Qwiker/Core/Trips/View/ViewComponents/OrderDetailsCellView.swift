//
//  OrderDetailsCellView.swift
//  Qwiker
//
//  Created by Bogdan Zykov on 05.11.2022.
//

import SwiftUI

struct OrderDetailsCellView: View{
    let trip: RequestedTrip?
    var body: some View{
        VStack {
            
            HStack(spacing: 20){
                Image(systemName: "info.circle")
                VStack(alignment: .leading){
                    Text("Order details")
                        .font(.poppinsMedium(size: 16))
                        .foregroundColor(.black)
                    if let tripCoast = trip?.tripCost{
                        Text("Your fare is \(tripCoast.toCurrency())")
                            .font(.poppinsRegular(size: 12))
                            .foregroundColor(.gray)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .imageScale(.small)
                    .foregroundColor(.gray)
            }
            
            Divider().padding(.horizontal, -16)
        }
    }
}

struct OrderDetailsCellView_Previews: PreviewProvider {
    static var previews: some View {
        OrderDetailsCellView(trip: dev.mockTrip)
    }
}
