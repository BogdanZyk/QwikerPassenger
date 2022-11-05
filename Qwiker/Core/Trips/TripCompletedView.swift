//
//  TripCompletedView.swift
//  Qwiker
//
//  Created by Богдан Зыков on 04.11.2022.
//

import SwiftUI

struct TripCompletedView: View {
    @EnvironmentObject var homeVM: HomeViewModel
    var body: some View {
        VStack(spacing: 30) {
            closeButton
            title
            RatingView().padding(.vertical)
            TipView()
            detailsButton
            submitButton
            Spacer()
        }
        .padding()
        .background(Color.primaryBg)
        .preferredColorScheme(.light)
    }
}

struct TripCompletedView_Previews: PreviewProvider {
    static var previews: some View {
        TripCompletedView()
            .environmentObject(dev.homeViewModel)
    }
}

extension TripCompletedView{
    private var closeButton: some View{
        Button {
            homeVM.isShowCompletedSheet.toggle()
        } label: {
         Image(systemName: "xmark")
                .imageScale(.small)
                .padding(10)
                .background{
                    Circle()
                        .fill(Color.secondary.opacity(0.2))
                }
        }
        .foregroundColor(.black)
        .hTrailing()
    }
    private var title: some View{
        VStack(spacing: 15) {
            Text("You've arrived! ").font(.poppinsMedium(size: 20))
            Text("\(homeVM.trip?.tripCost.toCurrency() ?? "")").font(.title2.bold())
        }
            
    }
    
    private var detailsButton: some View{
        Button {
            
        } label: {
            HStack{
                Image(systemName: "info.circle")
                Text("Details")
                Spacer()
                Image(systemName: "chevron.right")
            }
            .font(.poppinsRegular(size: 18))
            .foregroundColor(.black)
        }
    }
    
    private var submitButton: some View{
        PrimaryButtonView(title: "Done") {
            homeVM.isShowCompletedSheet.toggle()
        }
        .padding(.top, 20)
    }
}


