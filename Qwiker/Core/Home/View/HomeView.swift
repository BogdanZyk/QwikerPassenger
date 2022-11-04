//
//  HomeView.swift
//  Qwiker
//
//  Created by Богдан Зыков on 27.10.2022.
//

import SwiftUI

struct HomeView: View {
    @State private var showSideMenu: Bool = false
    @StateObject var searchVM = SearchViewModel()
    @StateObject var homeVM = HomeViewModel()
    @EnvironmentObject var authVM: AuthenticationViewModel
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                ZStack(alignment: .top){
                    DragMapView()
                    searchSection
                    mainHomeButton
                }
                sideMenuView
                    .onReceive(searchVM.$currentAppLocation) { location in
                        onReceiveForCurrentLocation(location)
                    }
                    .onReceive(searchVM.$destinationAppLocation) { location in
                        onReceiveForDestinationLocation(location)
                    }
                
                viewForState
                    .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)))
                
                
            }
            .environmentObject(searchVM)
            .environmentObject(homeVM)
            .navigationBarHidden(true)
            .edgesIgnoringSafeArea(.bottom)
            .sheet(isPresented: $homeVM.isShowCompletedSheet, onDismiss: {}) {
                TripCompletedView()
                    .environmentObject(homeVM)
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}



extension HomeView{
    private var sideMenuView: some View{
        Group{
            if showSideMenu {
                Color.gray.opacity(0.5).ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring()){
                            showSideMenu.toggle()
                        }
                    }
            }
            SideMenuView(isShowing: $showSideMenu)
                .frame(width: getRect().width - 50, alignment: .leading)
                .hLeading()
                .offset(x: showSideMenu ? 0 : -getRect().width)
        }
    }
    
    private var mainActionBtn: some View{
        Button {
            withAnimation {
                showSideMenu.toggle()
            }
        } label: {
            Circle()
                .fill(Color.white)
                .frame(width: 30, height: 30)
                .shadow(color: .black.opacity(0.4), radius: 5, x: 0, y: 0)
        }
        .hLeading()
        .padding()
    }
    
    private var locationSearchView: some View{
        LocationSearchView(mapState: $homeVM.mapState)
            .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)))
            .environmentObject(searchVM)
            
    }
    

}

//MARK: - onReceive actions

extension HomeView {
    private func onReceiveForCurrentLocation(_ location: AppLocation?){
        homeVM.userLocation = location
        if let userLocation = location, homeVM.mapState == .noInput{
            homeVM.fetchNearbyDrivers(withCoordinates: userLocation.coordinate)
        }
    }
    
    private func onReceiveForDestinationLocation(_ location: AppLocation?){
        homeVM.selectedLocation = location
    }
}


// MARK: Search section
extension HomeView {
    private var searchSection: some View{
        Group{
            if homeVM.mapState == .searchingForLocation{
                locationSearchView
            }else if homeVM.mapState == .noInput {
                searchActivationButton
            }
        }
    }
}

// MARK: Header section
extension HomeView {
    private var mainHomeButton: some View{
        Group{
            if homeVM.isShowMainActionButton{
                MainHomeActionButton(mapState: $homeVM.mapState, showSideMenu: $showSideMenu)
                    .padding(.leading)
                    .offset(y: homeVM.mapState == .locationSelected || homeVM.mapState == .polylineAdded ? getRect().height - getRect().height / 2.1 : 0)
                    .animation(nil, value: UUID().uuidString)
            }
        }

    }
    
    private var searchActivationButton: some View{
        VStack(spacing: 20){
            LocationSearchActivationView()
                .onTapGesture {
                    withAnimation(.easeInOut){
                        homeVM.mapState = .searchingForLocation
                    }
                }
        }
        .padding(.horizontal)
        .padding(.top, 60)
    }
}


extension HomeView{
    @ViewBuilder var viewForState: some View {
        //        guard let user = user else {
        //           return AnyView(EmptyView())
        //        }
        switch homeVM.mapState {
        case .tripRequested:
            AnyView(TripLoadingView())
        case .tripAccepted:
            AnyView(EnRouteToPickupLocationView())
        case .driverArrived:
            AnyView(DriverArrivalView())
        case .tripInProgress:
            AnyView(TripInProgressView())
        case .arrivedAtDestination:
            AnyView(EmptyView())
            //return AnyView(TripArrivalView(user: user))
        case .locationSelected:
            AnyView(RideRequestExpandSheetView())
        default:
            AnyView(EmptyView())
        }
    }
    
    @ViewBuilder var loaderView: some View{
        if homeVM.mapState == .tripRequested{
            AnyView(TripLoadingView())
        }
    }
}
