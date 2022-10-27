//
//  UserAvaterComponent.swift
//  Qwiker
//
//  Created by Богдан Зыков on 27.10.2022.
//

import SwiftUI

struct UserAvatarViewComponent: View {
    let pathImage: String?
    var size: CGSize = .init(width: 50, height: 50)
    var body: some View {
        Group{
            if let image = pathImage{
                CustomLazyImage(strUrl: image)
            }else{
                ZStack{
                    Color.gray
                }
            }
        }
        .frame(width: size.width, height: size.height)
        .clipShape(Circle())
    }
}

struct UserAvatarViewComponent_Previews: PreviewProvider {
    static var previews: some View {
        UserAvatarViewComponent(pathImage: nil)
    }
}
