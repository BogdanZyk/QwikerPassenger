//
//  RideType.swift
//  Qwiker
//
//  Created by Богдан Зыков on 27.10.2022.
//


import Foundation

enum RideType: Int, CaseIterable, Identifiable, Codable{
    case economy
    case comfort
    case bisness
    case sport
    
    var id: Int {rawValue}
    
    var title: String{
        switch self{
        case .economy:
            return "Econom"
        case .comfort:
            return "Comfort"
        case .bisness:
            return "Bisness"
        case .sport:
            return "Sport"
        }
    }
    
    var imageName: String{
        switch self{
        case .economy:
            return "economy-car"
        case .comfort:
            return "comfort-car"
        case .bisness:
            return "bisness-car"
        case .sport:
            return "sport-car"
        }
    }
    
    var aboutText: String{
        switch self {
        case .economy:
            return "Everyday trips"
        case .bisness:
            return "Business class travel"
        case .sport:
            return "Trips in a sports car"
        case .comfort:
            return "More comfort"
        }
    }
    
    var baseFare: Double{
        switch self{
        case .economy:
            return 2
        case .bisness:
            return 7
        case .comfort:
            return 10
        case .sport:
            return 15
        }
    }
    
    func price(for distanceInMeters: Double) -> Double{
        let distanceInMiles = distanceInMeters / 1600
        var price = 0.0
        
        switch self{
        case .economy:
            price = distanceInMiles * 1.1 + baseFare
        case .comfort:
            price = distanceInMiles * 1.3 + baseFare
        case .bisness:
            price = distanceInMiles * 1.5 + baseFare
        case .sport:
            price = distanceInMiles * 1.8 + baseFare
        }
        return price.roundToDecimal(2)
    }
}
