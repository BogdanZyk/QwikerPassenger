//
//  RideRequestExpandSheetView.swift
//  Qwiker
//
//  Created by Богдан Зыков on 28.10.2022.
//

import SwiftUI

struct RideRequestExpandSheetView: View {
    @EnvironmentObject var homeVM: HomeViewModel
    @State private var showPaymentInfoSheet: Bool = false
    var body: some View {
        ZStack(alignment: .bottom) {
            ExpandedView(minHeight: getRect().height / 3.2, maxHeight: getRect().height) { minHeight, rect, offset in
                SheetWithTabView(sheetHeight: minHeight, proxyFrame: rect, showPaymentInfoSheet: $showPaymentInfoSheet, offset: offset)
            }
            if showPaymentInfoSheet{
               PaymentInfoSheet(showPaymentInfoSheet: $showPaymentInfoSheet)
                    .zIndex(2)
                    .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom).combined(with: .opacity)))
            }
        }
        .padding(.bottom, 20)
    }
}

struct RideRequestExpandSheetView_Previews: PreviewProvider {
    static var previews: some View {
        RideRequestExpandSheetView()
            .environmentObject(dev.homeViewModel)
    }
}
