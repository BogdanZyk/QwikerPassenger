//
//  TripLoadingView.swift
//  Qwiker
//
//  Created by Богдан Зыков on 31.10.2022.
//

import SwiftUI

struct TripLoadingView: View {
    @EnvironmentObject var homeVM: HomeViewModel
    var body: some View {
        BottomSheetView {
            imageView
            loadingText
            loaderView
            cancelTripButtonView
        }
    }
}

struct TripLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack(alignment: .bottom){
            Color.gray
            TripLoadingView()
        }
        .ignoresSafeArea()
        .environmentObject(HomeViewModel())
    }
}




extension TripLoadingView{
    
    private var imageView: some View{
        Image("loading-img")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 160)
    }
    private var loadingText: some View{
        Text("Please hold! we are searching for nearby driver for you")
            .fixedSize(horizontal: false, vertical: true)
            .font(.poppinsMedium(size: 18))
            .multilineTextAlignment(.center)
    }
    private var loaderView: some View{
        Spinner(lineWidth: 12, height: 100, width: 100)
            .padding(.vertical, 12)
    }
    
    private var cancelTripButtonView: some View{
        PrimaryButtonView(showLoader: false, title: "Cancel Search", font: .poppinsMedium(size: 18)) {
            homeVM.cancelSearchTrip()
        }
    }
}
