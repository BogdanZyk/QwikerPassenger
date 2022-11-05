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
    init() {
        UIScrollView.appearance().bounces = false
    }
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
        VStack {
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
            }
            .padding(.bottom, 5)
            Divider()
        }
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
        VStack {
            
            HStack(spacing: 20){
                Image(systemName: "info.circle")
                VStack(alignment: .leading){
                    Text("Order details")
                        .font(.poppinsRegular(size: 16))
                        .foregroundColor(.black)
                    if let tripCoast = homeVM.trip?.tripCost{
                        Text("Your fare is \(tripCoast.toCurrency())")
                            .font(.callout)
                            .foregroundColor(.gray)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .imageScale(.small)
                    .foregroundColor(.gray)
            }
            
            Divider().padding(.horizontal, -16)
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



//extension EnRouteToPickupLocationView{
//    private var totalSectionView: some View{
//        HStack(spacing: 10){
//            VStack(alignment: .leading, spacing: 2){
//                if let trip = homeVM.trip{
//                    Text(trip.tripCost.formatted(.currency(code: "USD")))
//                        .font(.poppinsMedium(size: 20))
//
//                        .foregroundColor(.primaryBlue)
//                         Text("Price")
//                        .font(.poppinsRegular(size: 14))
//                        .foregroundColor(.gray)
//                }
//            }
//            Spacer()
//            PrimaryButtonView(showLoader: false, title: "Cancel Trip", font: .poppinsMedium(size: 18), bgColor: .red, fontColor: .red, isBackground: false, border: true) {
//                homeVM.cancelTrip()
//            }
//        }
//    }
//}


struct SheetWithScrollView <Content: View>: View{
    let content: Content
    var spacing: CGFloat
    
    init(spacing: CGFloat = 15,
         @ViewBuilder content: @escaping () -> Content ){
        
        self.content = content()
        self.spacing = spacing
    }
    
    var body: some View {
        VStack(spacing: 15) {
            Capsule()
                .fill(Color.secondary.opacity(0.2))
                .frame(width: 50, height: 6)
                .padding(.top, 6)
            ScrollView(.vertical, showsIndicators: false){
                VStack(spacing: spacing) {
                    content
                }
                .padding(.horizontal)
            }
        }
        .hCenter()
        .background(Color.primaryBg)
        .clipShape(CustomCorners(corners: [.topLeft, .topRight], radius: 12))
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 0)
        .onAppear{
            UIScrollView.appearance().bounces = false
        }
        .onDisappear{
            UIScrollView.appearance().bounces = true
        }
    }
}



struct CircleButtonWithTitle: View {
    let title: String
    let imageName: String
    let action: () -> Void
    var body: some View{
        Button {
            action()
        } label: {
            VStack{
                Image(systemName: imageName)
                    .imageScale(.medium)
                    .foregroundColor(.black)
                    .frame(width: 50, height: 50)
                    .background{Circle()
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.2), radius: 5)
                    }
                Text(title)
                    .font(.poppinsRegular(size: 14))
                    .foregroundColor(.gray)
            }
        }
    }
}
