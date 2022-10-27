//
//  String.swift
//  Qwiker
//
//  Created by Богдан Зыков on 27.10.2022.
//

import Foundation

extension String{
    
    mutating func formattingPhone() -> String{
        if self.first == "8"{
            self.replaceSubrange(...self.startIndex, with: "7")
        }
        return "+\(self)"
     }
    
    func isValidPhone() -> Bool {
        let phoneRegex = "^[0-9+]{0,1}+[0-9]{10,16}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phoneTest.evaluate(with: self)
    }
}
