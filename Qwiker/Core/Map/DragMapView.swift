//
//  DragMapView.swift
//  Qwiker
//
//  Created by Богдан Зыков on 27.10.2022.
//

import SwiftUI

struct DragMapView: View {
    @EnvironmentObject var homeVM: HomeViewModel
    @EnvironmentObject var searchVM: SearchViewModel
    var body: some View {
        ZStack{
            MapViewRepresentable()
                .ignoresSafeArea()
            if homeVM.mapState == .noInput{
                locationPin
                focusCurrentLocationButton
            }
            loaderView
        }
    }
}

struct DragMapView_Previews: PreviewProvider {
    static var previews: some View {
        DragMapView()
            .environmentObject(HomeViewModel())
            .environmentObject(SearchViewModel())
    }
}

extension DragMapView{
    private var locationPin: some View{
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(Color.primaryBlue)
                if searchVM.isAnimatePin{
                    Circle()
                        .fill(Color.white)
                        .frame(width: 10, height: 10)
                }
            }
            .frame(width: 30, height: 30)
            Rectangle()
                .fill(Color.primaryBlue)
                .frame(width: 3, height: 18)
        }
        .offset(y: -45)
    }
    
    private var focusCurrentLocationButton: some View{
        Button {
            searchVM.focusUserLocation()
        } label: {
            Image(systemName: "location.fill")
                .imageScale(.medium)
                .foregroundColor(.primaryBlue)
                .padding(10)
                .background{
                    Circle()
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 0)
                }
        }
        .padding()
        .hTrailing()
        .offset(y: getRect().height / 4)
    }
    
    private var loaderView: some View{
        Group{
            if homeVM.mapState == .tripRequested{
                Color.gray.ignoresSafeArea().opacity(0.3)
            }
        }
    }
}
