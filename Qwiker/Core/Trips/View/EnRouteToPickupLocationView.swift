//
//  EnRouteToPickupLocationView.swift
//  Qwiker
//
//  Created by Богдан Зыков on 31.10.2022.
//

import SwiftUI

struct EnRouteToPickupLocationView: View {
    @State private var showUserLocation: Bool = false
    @EnvironmentObject var homeVM: HomeViewModel
    var body: some View {
        ExpandedView(minHeight: getRect().height / 3, maxHeight: getRect().height / 1.2) { minHeight, rect, offset in
            SheetWithScrollView{
                title
                riderSectionView
                locationSectionView
                currentPaymentMethodSectionView
                showMeDriverToggle
                orderDetails
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
}

//MARK: - Location label section
extension EnRouteToPickupLocationView{
    
    private var locationSectionView: some View{
        VStack(spacing: 20) {
            LocationRowsViewComponent(selectLocationTitle: homeVM.userLocation?.title, destinationLocationTitle: homeVM.selectedLocation?.title)
            CustomDivider(lineHeight: 15).padding(.horizontal, -16)
        }
    }
    
}

//MARK: - Payment Method Section View

extension EnRouteToPickupLocationView{
    private var currentPaymentMethodSectionView: some View{
        CurrentPaymentMethodCellView()
    }
    
    private var showMeDriverToggle: some View{
        VStack {
            Toggle(isOn: $showUserLocation) {
                HStack(spacing: 20) {
                    Image(systemName: "location.fill")
                    Text("Show the driver where I am")
                        .font(.poppinsRegular(size: 16))
                }
                
            }
            .tint(.primaryBlue)
            .padding(.bottom, 5)
            Divider()
        }
    }
    
    private var orderDetails: some View{
        OrderDetailsCellView(trip: homeVM.trip)
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











