//
//  SideMenuOptionType.swift
//  Qwiker
//
//  Created by Богдан Зыков on 27.10.2022.
//

import Foundation

enum SideMenuOptionViewType: Int, CaseIterable {
    case trips
    case wallet
    case settings
    case support
    
    var title: String {
        switch self {
        case .trips: return "Your Trips"
        case .wallet: return "Wallet"
        case .settings: return "Settings"
        case .support: return "Support"
        }
    }
    
    var imageName: String {
        switch self {
        case .trips: return "list.bullet.rectangle"
        case .wallet: return "creditcard"
        case .settings: return "gear"
        case .support: return "bubble.left"
        }
    }
}
