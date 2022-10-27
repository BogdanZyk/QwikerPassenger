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
            MapViewRepresentable(mapState: $homeVM.mapState)
                .ignoresSafeArea()
            if homeVM.mapState == .noInput{
                locationPin
            }
        }
    }
}

struct DragMapView_Previews: PreviewProvider {
    static var previews: some View {
        DragMapView()
            .environmentObject(SearchViewModel())
    }
}

extension DragMapView{
    private var locationPin: some View{
        VStack(spacing: 0) {
            ZStack {
                Circle()
                if searchVM.isAnimatePin{
                    Circle()
                        .fill(Color.white)
                        .frame(width: 10, height: 10)
                }
            }
            .frame(width: 30, height: 30)
            Rectangle()
                .frame(width: 3, height: 18)
        }
        .offset(y: -45)
    }
}
