//
//  RideType.swift
//  Qwiker
//
//  Created by Богдан Зыков on 27.10.2022.
//


import Foundation

enum RideType: Int, CaseIterable, Identifiable, Codable{
    case uberx
    case black
    case uberXL
    case select
    
    var id: Int {rawValue}
    
    var title: String{
        switch self{
        case .uberx:
            return "UberX"
        case .black:
            return "Black"
        case .uberXL:
            return "UberXL"
        case .select:
            return "Select"
        }
    }
    
    var imageName: String{
        switch self{
        case .uberx:
            return "uber-x"
        case .black:
            return "uber-black"
        case .uberXL:
            return "uber-x"
        case .select:
            return "uber-x"
        }
    }
    
    var aboutText: String{
        switch self {
        case .uberx:
            return "Everyday trips"
        case .black:
            return "Business class travel"
        case .uberXL:
            return "More space"
        case .select:
            return "More comfort"
        }
    }
    
    var baseFare: Double{
        switch self{
        case .uberx:
            return 5
        case .black:
            return 20
        case .uberXL:
            return 10
        case .select:
            return 15
        }
    }
    
    func price(for distanceInMeters: Double) -> Double{
        let distanceInMiles = distanceInMeters / 1600
        
        switch self{
        case .uberx:
            return distanceInMiles * 1.5 + baseFare
        case .black:
            return distanceInMiles * 2.0 + baseFare
        case .uberXL:
            return distanceInMiles * 1.75 + baseFare
        case .select:
            return distanceInMiles * 1.85 + baseFare
        }
    }
}
