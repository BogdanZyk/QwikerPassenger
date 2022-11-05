//
//  EnRouteToPickupLocationView.swift
//  Qwiker
//
//  Created by Богдан Зыков on 31.10.2022.
//

import SwiftUI

struct EnRouteToPickupLocationView: View {

    @EnvironmentObject var homeVM: HomeViewModel
    var body: some View {
        ExpandedView(minHeight: getRect().height / 3, maxHeight: getRect().height / 1.2) { minHeight, rect, offset in
            SheetWithScrollView{
                title
                riderSectionView
                tripInfoSection
                buttonsSectionView
            }
        }
    }
}

struct EnRouteToPickupLocationView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack(alignment: .bottom){
            Color.gray.ignoresSafeArea()
            EnRouteToPickupLocationView()
        }
        
        .environmentObject(dev.homeViewModel)
    }
}

//MARK: - Rider section view

extension EnRouteToPickupLocationView{
    private var title: some View{
        VStack(spacing: 10) {
            Text("Arriving in \(homeVM.currentRoute?.expectedTravelTime.stringTimeInMinutes ?? "~10 min")")
                .font(.title2.bold())
            if let trip = homeVM.trip{
                HStack{
                    Text(trip.carInfo)
                        .font(.poppinsRegular(size: 18))
                    Text(trip.carNumber ?? "")
                        .font(.title3.bold())
                }
            }
        }
    }

    private var riderSectionView: some View{
        HStack(spacing: 50){
            if let trip = homeVM.trip{
                RiderInfoView(trip: trip)
                CircleButtonWithTitle(title: "Contact", imageName: "phone.bubble.left.fill"){}
            }
        }
        .padding(.vertical, 10)
    }
    
    @ViewBuilder
    private var tripInfoSection: some View{
        if let trip = homeVM.trip{
            TripDetailsInfoView(isHiddenUserLocationToogle: false, trip:trip)
        }
    }
}


extension EnRouteToPickupLocationView{
    private var buttonsSectionView: some View{
        HStack{
            Spacer()
            CircleButtonWithTitle(title: "Cancel order", imageName: "xmark") {
                homeVM.cancelTrip()
            }
            Spacer()
            CircleButtonWithTitle(title: "Share route", imageName: "arrowshape.turn.up.right.fill") {
            }
            Spacer()
            CircleButtonWithTitle(title: "Safety", imageName: "shield.lefthalf.filled") {
            }
            Spacer()
        }
        .padding(.top)
    }
}











