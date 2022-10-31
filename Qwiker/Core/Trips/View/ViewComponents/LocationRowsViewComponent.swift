//
//  LocationRowsViewComponent.swift
//  Qwiker
//
//  Created by Bogdan Zykov on 01.11.2022.
//

import SwiftUI

struct LocationRowsViewComponent: View {
    var selectLocationTitle: String?
    var destinationLocationTitle: String?
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            locationLabel()
            Rectangle()
                .fill(Color.primaryBlue)
                .frame(width: 1, height: 12)
                .padding(.horizontal, 3)
            locationLabel(isDestination: true)
        }
    }
}

struct LocationRowsViewComponent_Previews: PreviewProvider {
    static var previews: some View {
        LocationRowsViewComponent()
    }
}


extension LocationRowsViewComponent{
    private func locationLabel(isDestination: Bool = false) -> some View{
        HStack(alignment: .lastTextBaseline) {
            Circle()
                .fill(isDestination ? Color.primaryBlue : Color.secondaryGrey)
                .frame(width: 8, height: 8)
            VStack(alignment: .leading, spacing: 15){
                HStack(spacing: 10) {
                    Text(isDestination ? destinationLocationTitle ?? "Destination" : selectLocationTitle ?? "Current location")
                        .lineLimit(1)
                        .font(.subheadline.weight(.medium))
                     .foregroundColor(Color.black)
                }
            }
        }
        .hLeading()
    }

}
