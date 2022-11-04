//
//  TripCompletedView.swift
//  Qwiker
//
//  Created by Богдан Зыков on 04.11.2022.
//

import SwiftUI

struct TripCompletedView: View {
    @State private var rating: Int = 0
    @State private var currentTip: TipModel? = nil
    @EnvironmentObject var homeVM: HomeViewModel
    var body: some View {
        VStack(spacing: 30) {
            closeButton
            title
            RatingView(rating: $rating).padding(.vertical)
            tipView
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
        Text("You've arrived: ").font(.poppinsMedium(size: 20)) + Text("\(homeVM.trip?.tripCost.toCurrency() ?? "")").font(.title2.bold())
            
    }
    
    private var detailsButton: some View{
        Button {
            
        } label: {
            HStack{
                Image(systemName: "exclamationmark.circle")
                Text("Details")
                Spacer()
                Image(systemName: "chevron.right")
            }
            .font(.poppinsRegular(size: 20))
            .foregroundColor(.black)
        }
    }
    
    private var tipView: some View{
        VStack(spacing: 20) {
            Text("Tip for the driver")
                .font(.title3.weight(.medium))
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15){
                    ForEach(TipModel.allCases, id: \.self){tip in
                        Text(tip.value.toCurrency())
                            .font(.headline.bold())
                            .foregroundColor(currentTip == tip ? .white : .black)
                            .padding(15)
                            .background{
                                Capsule()
                                    .fill(currentTip == tip ? Color.primaryBlue : Color.white)
                                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 0)
                            }
                            .onTapGesture {
                                withAnimation {
                                    currentTip = tip
                                }
                            }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 5)
            }
            .padding(.horizontal, -16)
        }
    }
    private var submitButton: some View{
        PrimaryButtonView(title: "Done") {
            homeVM.isShowCompletedSheet.toggle()
        }
        .padding(.top, 20)
    }
}

enum TipModel: Int, CaseIterable{
    case one, tree, five, ten, twenty
    
    var value: Double{
        switch self {
        case .one:
            return 1.0
        case .tree:
            return 3.0
        case .five:
            return 5.0
        case .ten:
            return 10.0
        case .twenty:
            return 20.0
        }
    }
}
