//
//  Helpers.swift
//  Qwiker
//
//  Created by Богдан Зыков on 27.10.2022.
//

import SwiftUI

final class Helpers{
    
    static func openSettings(){
        guard let settingURL = URL(string: UIApplication.openSettingsURLString) else {return}
        if UIApplication.shared.canOpenURL(settingURL){
            UIApplication.shared.open(settingURL)
        }
    }
    
}


