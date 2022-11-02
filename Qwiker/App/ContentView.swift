//
//  ContentView.swift
//  Qwiker
//
//  Created by Богдан Зыков on 27.10.2022.
//

import SwiftUI

struct ContentView: View {
    @StateObject var locationManager = LocationManager.shared
    @StateObject var authViewModel = AuthenticationViewModel()
    var body: some View {
        
        Group{
            if authViewModel.userSession == nil{
                LoginView()
                    .environmentObject(authViewModel)
            }else{
                HomeView()
                    .environmentObject(authViewModel)
            }
        }
        .alert("Allow your location in the settings", isPresented: $locationManager.showAlert) {
            Button("Open settings", action: Helpers.openSettings)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
