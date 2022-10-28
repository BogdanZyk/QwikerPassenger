//
//  Double.swift
//  Qwiker
//
//  Created by Богдан Зыков on 28.10.2022.
//

import Foundation


extension Double {
    func roundToDecimal(_ fractionDigits: Int) -> Double {
        let multiplier = pow(10, Double(fractionDigits))
        return Darwin.round(self * multiplier) / multiplier
    }
}
