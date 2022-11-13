//
//  SideMenuOptionType.swift
//  Qwiker
//
//  Created by Богдан Зыков on 27.10.2022.
//

import Foundation

enum SideMenuOptionViewType: Int, CaseIterable {
    case trips
    case promocode
    case settings
    case support
    case share
    
    var title: String {
        switch self {
        case .trips: return "Your Trips"
        case .promocode: return "Promocodes"
        case .settings: return "Settings"
        case .support: return "Support"
        case .share: return "Invite friends"
        }
    }
    
    var imageName: String {
        switch self {
        case .trips: return "list.bullet.circle.fill"
        case .promocode: return "bookmark.circle.fill"
        case .settings: return "gear.circle.fill"
        case .support: return "bubble.left"
        case .share: return "arrowshape.turn.up.forward.circle.fill"
        }
    }
}
