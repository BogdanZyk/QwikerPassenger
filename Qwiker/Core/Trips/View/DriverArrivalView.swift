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
        BottomSheetView(spacing: 20, maxHeightForBounds: 2.5) {
            title
            riderInfo
            locationSectionView
            cancelButton
        }
        .alert("Cancelling a trip", isPresented: $isPresented) {
            Button("Yes", role: .destructive){
                homeVM.cancelTrip()
            }
        } message: {
            Text("Are you sure you want to cancel the trip?")
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
        Text("Your driver is here!")
            .font(.poppinsMedium(size: 20))
    }
    
 
  @ViewBuilder private var riderInfo: some View{
        if let trip = homeVM.trip{
            RiderInfoView(trip: trip)
        }
    }
    
    private var locationSectionView: some View{
        LocationRowsViewComponent(selectLocationTitle: homeVM.userLocation?.title, destinationLocationTitle: homeVM.selectedLocation?.title)
    }
    
    private var cancelButton: some View{
        PrimaryButtonView(showLoader: false, title: "Cancel Trip", font: .poppinsMedium(size: 18), bgColor: .red, fontColor: .red, isBackground: false, border: true) {
            isPresented.toggle()
        }
        .padding(.top, 15)
    }
}
