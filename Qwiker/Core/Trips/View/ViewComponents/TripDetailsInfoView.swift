//
//  TripDetailsInfoView.swift
//  Qwiker
//
//  Created by Bogdan Zykov on 05.11.2022.
//

import SwiftUI

struct TripDetailsInfoView: View {
    var isHiddenUserLocationToogle: Bool = true
    @State private var showUserLocation: Bool = false
    let trip: RequestedTrip
    var body: some View {
        VStack(spacing: 10){
            LocationRowsViewComponent(selectLocationTitle: trip.pickupLocationName, destinationLocationTitle: trip.dropoffLocationName)
            CustomDivider(verticalPadding: 0, lineHeight: 15).padding(.horizontal, -16)
            CurrentPaymentMethodCellView()
            if !isHiddenUserLocationToogle{
                showMeDriverToggle
            }
            OrderDetailsCellView(trip: trip)
        }
    }
}

struct TripDetailsInfoView_Previews: PreviewProvider {
    static var previews: some View {
        TripDetailsInfoView(trip: dev.mockTrip)
    }
}



extension TripDetailsInfoView{
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
}
