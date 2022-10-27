//
//  LocationResultViewCell.swift
//  Qwiker
//
//  Created by Bogdan Zykov on 28.10.2022.
//

import SwiftUI

struct LocationResultViewCell: View {
    let title: String
    let subtitle: String
    var body: some View {
        VStack(alignment: .leading, spacing: 4){
            Text(title)
                .font(.poppinsRegular(size: 16))
                .foregroundColor(.black)
            Text(subtitle)
                .multilineTextAlignment(.leading)
                .font(.poppinsRegular(size: 14))
                .foregroundColor(Color(.systemGray))
            Divider()
        }
    }
}

struct LocationResultViewCell_Previews: PreviewProvider {
    static var previews: some View {
        LocationResultViewCell(title: "Starbucks Coffee", subtitle: "123 Main St, Cupertino CA")
    }
}
