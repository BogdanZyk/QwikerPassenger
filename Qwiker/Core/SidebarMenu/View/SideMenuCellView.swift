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
                .font(.title2)
                .imageScale(.medium)
            
            Text(optionType.title)
                .font(.system(size: 16, weight: .semibold))
            
            Spacer()
        }
        .foregroundColor(.black)
        .padding(.vertical)
    }
}

struct SideMenuOptionView_Previews: PreviewProvider {
    static var previews: some View {
        SideMenuOptionView(optionType: .wallet)
    }
}
