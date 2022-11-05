//
//  TimeInterval.swift
//  Qwiker
//
//  Created by Богдан Зыков on 04.11.2022.
//

import Foundation


extension TimeInterval {
    
  
    private var minutes: Int {
        return (Int(self) / 60 ) % 60
    }


    var stringTimeInMinutes: String {
         "~\(minutes) min"
    }
}
