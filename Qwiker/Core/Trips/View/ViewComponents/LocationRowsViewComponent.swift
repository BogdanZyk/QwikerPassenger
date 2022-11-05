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
        VStack(alignment: .leading, spacing: 10) {
            locationLabel()
            Divider().padding(.leading)
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
        HStack(alignment: .center, spacing: 15) {
            Circle()
                .stroke(lineWidth: 3)
                .fill(isDestination ? Color.primaryBlue : Color.secondaryGrey)
                .frame(width: 12, height: 12)
            VStack(alignment: .leading, spacing: 4){
                    Text(isDestination ? destinationLocationTitle ?? "Destination" : selectLocationTitle ?? "Current location")
                        .lineLimit(1)
                        .font(.headline.weight(.medium))
                     .foregroundColor(Color.black)
                Text(isDestination ? "Change destination" : "Specify entrance")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
    }

}
