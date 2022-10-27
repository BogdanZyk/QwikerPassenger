//
//  FontsExt.swift
//  Qwiker
//
//  Created by Богдан Зыков on 27.10.2022.
//


import SwiftUI


extension Font {
    
    static func medelRegular(size: Int) -> Font {
        Font.custom("Medel", size: CGFloat(size))
    }
    static func poppinsRegular(size: Int) -> Font {
        Font.custom("Poppins-Regular", size: CGFloat(size))
    }
    static func poppinsMedium(size: Int) -> Font {
        Font.custom("Poppins-Medium", size: CGFloat(size))
    }
}
