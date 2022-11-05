//
//  RiderInfoView.swift
//  Qwiker
//
//  Created by Bogdan Zykov on 01.11.2022.
//

import SwiftUI

struct RiderInfoView: View {
    var isHiddenName: Bool = false
    let trip: RequestedTrip
    var body: some View {
        VStack(spacing: 5){
            UserAvatarViewComponent(pathImage: trip.driverImageUrl, size: CGSize(width: 60, height: 60))
            HStack {
                if !isHiddenName{
                    Text(trip.driverFirstName)
                        .font(.poppinsRegular(size: 16))
                }
                Text("4.9")
                    .font(.poppinsRegular(size: 16))
                    .foregroundColor(.gray)
                Image(systemName: "star")
                    .imageScale(.small)
                    .foregroundColor(.gray)
            }
        }
    }
}

struct RiderInfoView_Previews: PreviewProvider {
    static var previews: some View {
        RiderInfoView(trip: dev.mockTrip)
    }
}


extension RiderInfoView{
    private var driveActionButton: some View{
        HStack(spacing: 5){
            Image(systemName: "phone.fill")
                .imageScale(.small)
                .foregroundColor(.white)
                .padding(8)
                .background(Color.primaryBlue, in: Circle())
            Image(systemName: "text.bubble.fill")
                .imageScale(.small)
                .foregroundColor(.white)
                .padding(8)
                .background(Color.primaryBlue, in: Circle())
        }
    }
}
