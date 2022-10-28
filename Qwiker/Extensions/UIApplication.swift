//
//  UIApplication.swift
//  Qwiker
//
//  Created by Богдан Зыков on 28.10.2022.
//


import Foundation
import SwiftUI

extension UIApplication {
    
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
}


