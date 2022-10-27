//
//  HomeView.swift
//  Qwiker
//
//  Created by Богдан Зыков on 27.10.2022.
//

import SwiftUI

struct HomeView: View {
    @StateObject var searchVM = SearchViewModel()
    @StateObject var homeVM = HomeViewModel()
    @EnvironmentObject var authVM: AuthenticationViewModel
    var body: some View {
        ZStack{
            MapViewRepresentable(mapState: $homeVM.mapState)
                .ignoresSafeArea()
                .environmentObject(searchVM)
            Button {
                authVM.signOut()
            } label: {
                Text("signOut")
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
