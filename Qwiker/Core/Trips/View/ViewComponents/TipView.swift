//
//  TipView.swift
//  Qwiker
//
//  Created by Bogdan Zykov on 05.11.2022.
//

import SwiftUI

struct TipView: View {
    @State private var currentTip: TipModel? = nil
    var body: some View {
        VStack(spacing: 20) {
            Text("Tip")
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
}

struct TipView_Previews: PreviewProvider {
    static var previews: some View {
        TipView()
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
