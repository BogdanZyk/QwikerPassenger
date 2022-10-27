//
//  LocationSearchActivationView.swift
//  Qwiker
//
//  Created by Bogdan Zykov on 27.10.2022.
//

import SwiftUI

struct LocationSearchActivationView: View {
    @EnvironmentObject var searchVM: SearchViewModel
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(searchVM.currentAppLocation?.title ?? "Current location")
                .lineLimit(1)
                .font(.poppinsMedium(size: 12))
                .foregroundColor(Color(.darkGray))
                .padding(.leading, 15)
            HStack(spacing: 10){
                Circle()
                    .fill(Color.primaryBlue)
                    .frame(width: 8, height: 8)
                Text("Where do you want to go?")
                    .font(.poppinsMedium(size: 18))
                Spacer()
            }
        }
        .padding(.horizontal)
        .frame(height: 50)
        .background{
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.2), radius: 6)
        }
    }
}

struct ActionSearchView_Previews: PreviewProvider {
    static var previews: some View {
        LocationSearchActivationView()
            .padding()
            .environmentObject(SearchViewModel())
    }
}
