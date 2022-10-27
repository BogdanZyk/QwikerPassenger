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
            }
            .environmentObject(searchVM)
            .environmentObject(homeVM)
            .navigationBarHidden(true)
            .edgesIgnoringSafeArea(.bottom)
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
            .transition(.move(edge: .bottom))
            .environmentObject(searchVM)
            
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
        MainHomeActionButton(mapState: $homeVM.mapState, showSideMenu: $showSideMenu)
            .padding(.leading)
            .offset(y: homeVM.mapState == .locationSelected || homeVM.mapState == .polylineAdded ? getRect().height - getRect().height / 2.1 : 0)
            .animation(nil, value: UUID().uuidString)
    }
    
    private var searchActivationButton: some View{
        VStack(spacing: 20){
            LocationSearchActivationView()
                .onTapGesture {
                    withAnimation(.spring()){
                        homeVM.mapState = .searchingForLocation
                    }
                }
        }
        .padding(.horizontal)
        .padding(.top, 60)
    }
}
