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
                    mainActionBtn
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
}
