//
//  TripInProgressView.swift
//  Qwiker
//
//  Created by Богдан Зыков on 31.10.2022.
//

import SwiftUI

struct TripInProgressView: View {
    @EnvironmentObject var homeVM: HomeViewModel
    init(){
        UIScrollView.appearance().isScrollEnabled = false
    }
    var body: some View {
        ExpandedView(minHeight: getRect().height / 3.5, maxHeight: getRect().height / 1.2) { minHeight, rect, offset in
            SheetWithScrollView{
                title
                driverViewCell
                ratingView
                TipView().padding(.vertical)
                tripInfoSection
                buttonsSectionView
            }
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
        VStack {
            Text(" \(homeVM.currentRoute?.expectedTravelTime.stringTimeInMinutes ?? "10 min") left")
                .font(.title2.bold())
            Text("How's your ride?")
                .font(.poppinsRegular(size: 18))
        }
        
    }
    private var ratingView: some View{
        RatingView()
    }
    
    private var driverViewCell: some View{
        HStack(spacing: 30) {
            if let trip = homeVM.trip{
                RiderInfoView(isHiddenName: true, trip: trip)
                CircleButtonWithTitle(title: "Safety", imageName: "shield.lefthalf.filled") {
                }
            }
        }
    }
    
   @ViewBuilder
    private var tripInfoSection: some View{
        if let trip = homeVM.trip{
            TripDetailsInfoView(trip: trip)
        }
    }
    
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
        }
        .padding(.vertical)
    }
   
}




