//
//  DriverArrivalView.swift
//  Qwiker
//
//  Created by Богдан Зыков on 31.10.2022.
//

import SwiftUI

struct DriverArrivalView: View {
    @State private var isPresented: Bool = false
    @EnvironmentObject var homeVM: HomeViewModel
    var body: some View {
        ExpandedView(minHeight: getRect().height / 4, maxHeight: getRect().height / 1.2) { minHeight, rect, offset in
            SheetWithScrollView{
                title
                actionButtonsSection
                tripInfoSection
                bottomActionButtons
            }
        }
        .alert("Cancelling a order", isPresented: $isPresented) {
            Button("Yes", role: .destructive){
                homeVM.cancelTrip()
            }
        } message: {
            Text("Are you sure you want to cancel the order?")
        }
    }
}

struct DriverArrivalView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack(alignment: .bottom) {
            Color.gray
            DriverArrivalView()
        }
        .ignoresSafeArea()
        .environmentObject(dev.homeViewModel)
    }
}


extension DriverArrivalView{
    private var title: some View{
        VStack(spacing: 10) {
            Text("Your taxi is here")
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
    
    private var actionButtonsSection: some View{
        HStack{
            Spacer()
            CircleButtonWithTitle(title: "Call", imageName: "phone.fill", action: {})
            Spacer()
            CircleButtonWithTitle(title: "Chat", imageName: "text.bubble.fill", action: {})
            Spacer()
            CircleButtonWithTitle(title: "On my way", imageName: "figure.walk", action: {})
            Spacer()
        }
        .padding(.vertical, 10)
    }
 @ViewBuilder
    private var tripInfoSection: some View{
        if let trip = homeVM.trip{
            TripDetailsInfoView(trip: trip)
        }
    }
    
    private var bottomActionButtons: some View{
        HStack{
            Spacer()
            CircleButtonWithTitle(title: "Cancel order", imageName: "xmark") {
                isPresented.toggle()
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
