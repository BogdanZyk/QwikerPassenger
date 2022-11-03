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
        BottomSheetView(spacing: 20, maxHeightForBounds: 2.5) {
                title
                rideSectionView
                locationSectionView
                currentPaymentMethodSectionView
                totalSectionView
            Spacer()
        }
        
    }
}

struct EnRouteToPickupLocationView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack(alignment: .bottom){
            Color.gray
            EnRouteToPickupLocationView()
        }
        .ignoresSafeArea()
        .environmentObject(dev.homeViewModel)
    }
}

//MARK: - Rider section view

extension EnRouteToPickupLocationView{
    private var title: some View{
        Text("Your Ride is arriving in \(homeVM.dropOffTime ?? "3 mins")")
            .font(.poppinsMedium(size: 18))
    }
    
    private var rideSectionView: some View{
        Group{
            if let trip = homeVM.trip{
                RiderInfoView(trip: trip)
            }
        }
    }

}

//MARK: - Location label section
extension EnRouteToPickupLocationView{
    
    private var locationSectionView: some View{
        LocationRowsViewComponent(selectLocationTitle: homeVM.userLocation?.title, destinationLocationTitle: homeVM.selectedLocation?.title)
    }
    
}

//MARK: - Payment Method Section View

extension EnRouteToPickupLocationView{
    private var currentPaymentMethodSectionView: some View{
        Button {
            
        } label: {
            HStack(spacing: 20){
                Image("cash-icon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .padding(5)
                    .background(Color.white, in: Circle())
                VStack(alignment: .leading, spacing: 4){
                    Text("Cash")
                        .foregroundColor(.black)
                        .font(.poppinsMedium(size: 18))
                    Text("Change Payment method")
                        .font(.poppinsRegular(size: 12))
                        .foregroundColor(.gray)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .imageScale(.small)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 10)
            .padding(.horizontal)
            .hCenter()
            .background(Color.secondary.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))
        }
    }
}


extension EnRouteToPickupLocationView{
    private var totalSectionView: some View{
        HStack(spacing: 10){
            VStack(alignment: .leading, spacing: 2){
                if let trip = homeVM.trip{
                    Text(trip.tripCost.formatted(.currency(code: "USD")))
                        .font(.poppinsMedium(size: 20))
                        
                        .foregroundColor(.primaryBlue)
                         Text("Price")
                        .font(.poppinsRegular(size: 14))
                        .foregroundColor(.gray)
                }
            }
            Spacer()
            PrimaryButtonView(showLoader: false, title: "Cancel Trip", font: .poppinsMedium(size: 18), bgColor: .red, fontColor: .red, isBackground: false, border: true) {
                homeVM.cancelTrip()
            }
        }
    }
}


