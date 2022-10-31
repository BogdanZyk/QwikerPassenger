//
//  MainHomeActionButton.swift
//  Qwiker
//
//  Created by Bogdan Zykov on 27.10.2022.
//

import SwiftUI

struct MainHomeActionButton: View {
    @EnvironmentObject var homeVM: HomeViewModel
    @EnvironmentObject var locationSearchVM: SearchViewModel
    @Binding var mapState: MapViewState
    @Binding var showSideMenu: Bool
    var body: some View {
        Button {
            withAnimation(.easeInOut){
                actionForState()
            }
        } label: {
            Image(systemName: iconName)
                .font(.title3.weight(.medium))
                .foregroundColor(.black)
                .frame(width: 40, height: 40)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(color: .black.opacity(0.2), radius: 6)
        }
        .hLeading()
    }
}

struct MainHomeActionButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            MainHomeActionButton(mapState: .constant(.noInput), showSideMenu: .constant(true))
            MainHomeActionButton(mapState: .constant(.locationSelected), showSideMenu: .constant(true))
        }
        .padding()
        .environmentObject(SearchViewModel())
        .environmentObject(dev.homeViewModel)
    }
}

extension MainHomeActionButton{
    private func actionForState(){
        switch mapState {
        case .noInput:
            withAnimation(.spring()) {
                showSideMenu.toggle()
            }
            homeVM.setCurrentUserRegion()
        case .searchingForLocation:
            UIApplication.shared.endEditing()
            mapState = .noInput
        case .locationSelected, .polylineAdded:
            mapState = .noInput
            homeVM.setCurrentUserRegion()
        case .tripRequested:
            mapState = .noInput
            homeVM.setCurrentUserRegion()
            
        default: break
        }
    }
    
    private var iconName: String{
        switch mapState{
        case .searchingForLocation,
                .locationSelected,
                .tripAccepted,
                .tripRequested,
                .tripCompleted,
                .polylineAdded:
            return "chevron.left"
        case .noInput, .tripCancelled:
            return "line.3.horizontal"
        default:
            return "line.3.horizontal"
        }
    }
}

