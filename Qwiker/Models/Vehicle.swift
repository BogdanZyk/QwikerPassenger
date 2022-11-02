//
//  Vehicle.swift
//  Qwiker
//
//  Created by Богдан Зыков on 27.10.2022.
//


import Foundation

struct Vehicle: Codable {
    let make: String
    let model: String
    let year: String
    let color: VehicleColors
    let licensePlateNumber: String
    let type: RideType
    let number: String
}

enum VehicleColors: Int, CaseIterable, Identifiable, Codable {
    case black
    case white
    case red
    case yellow
    case gray
    case silver
    case blue
    case tan
    
    var id: Int { self.rawValue }
    
    var description: String {
        switch self {
        case .black: return "Black"
        case .white: return "White"
        case .red: return "Red"
        case .yellow: return "Yellow"
        case .gray: return "Gray"
        case .silver: return "Silver"
        case .blue: return "Blue"
        case .tan: return "Tan"
        }
    }
}
