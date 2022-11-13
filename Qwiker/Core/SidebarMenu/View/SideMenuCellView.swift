//
//  SideMenuCellView.swift
//  Qwiker
//
//  Created by Богдан Зыков on 27.10.2022.
//

import SwiftUI

struct SideMenuOptionView: View {
    let optionType: SideMenuOptionViewType
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: optionType.imageName)
                .font(.title)
                .foregroundColor(.gray)
            
            Text(optionType.title)
                .font(.poppinsMedium(size: 18))
            
            Spacer()
            Image(systemName: "chevron.right")
        }
        .foregroundColor(.black)
        .padding(.vertical)
    }
}

struct SideMenuOptionView_Previews: PreviewProvider {
    static var previews: some View {
        SideMenuOptionView(optionType: .promocode)
    }
}
