//
//  RiderInfoView.swift
//  Qwiker
//
//  Created by Bogdan Zykov on 01.11.2022.
//

import SwiftUI

struct RiderInfoView: View {
    let trip: RequestedTrip
    var isHiddenButton: Bool = false
    var body: some View {
        HStack(alignment: .top, spacing: 15){
            UserAvatarViewComponent(pathImage: trip.driverImageUrl, size: CGSize(width: 55, height: 55))
            VStack(alignment: .leading, spacing: 2){
                Label {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("4.9")
                        .font(.poppinsRegular(size: 14))
                        .foregroundColor(.gray)
                } icon: {
                    Text(trip.driverName)
                        .font(.poppinsMedium(size: 16))
                }
                Text("\(trip.carColor ?? "") \(trip.carModel ?? "") ").font(.poppinsMedium(size: 14))
                Text(trip.carNumber ?? "").font(.poppinsRegular(size: 14)).foregroundColor(.gray)
            }
            Spacer()
            if !isHiddenButton{
                driveActionButton
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
