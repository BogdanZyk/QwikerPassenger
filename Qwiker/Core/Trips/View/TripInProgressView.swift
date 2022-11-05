//
//  TripInProgressView.swift
//  Qwiker
//
//  Created by Богдан Зыков on 31.10.2022.
//

import SwiftUI

struct TripInProgressView: View {
    @State private var rating: Int = 0
    @EnvironmentObject var homeVM: HomeViewModel
    var body: some View {
        BottomSheetView(spacing: 15, maxHeightForBounds: 4) {
            title
            driverViewCell
            Divider()
            RatingView(rating: $rating)
        }
    }
}

struct TripInProgressView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack(alignment: .bottom) {
            Color.gray.ignoresSafeArea()
            TripInProgressView()
        }
        .environmentObject(dev.homeViewModel)
    }
}

extension TripInProgressView{
    private var title: some View{
        HStack {
            Text("On the way")
                .font(.poppinsMedium(size: 20))
            Text("~ \(homeVM.currentRoute?.expectedTravelTime.stringTimeInMinutes ?? "10 min")")
                .font(.poppinsMedium(size: 16))
                .foregroundColor(.gray)
        }
        
    }
    
    private var driverViewCell: some View{
        Group{
            if let trip = homeVM.trip{
                HStack {
                    RiderInfoView(trip: trip)
                    Spacer()
                    detailsButton
                }
            }
        }
    }
    
    private var detailsButton: some View{
        Button {
            
        } label: {
            VStack {
                Image(systemName: "line.3.horizontal")
                    
                    .padding()
                    .background{
                        Circle()
                            .fill(Color.secondaryGrey.opacity(0.4))
                }
                Text("Details")
                    .font(.caption)
            }
            .foregroundColor(.black)
        }
    }
}




