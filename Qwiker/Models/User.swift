//
//  User.swift
//  Qwiker
//
//  Created by Богдан Зыков on 27.10.2022.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import CoreLocation
import Firebase
import GeoFire

struct User: Codable {
    @DocumentID var id: String?
    let fullname: String
    let email: String
    var phoneNumber: String
    var profileImageUrl: String?
    var homeLocation: SavedLocation?
    var workLocation: SavedLocation?
    var coordinates: GeoPoint
    
    var uid: String { return id ?? "" }
}

struct SavedLocation: Codable {
    let title: String
    let address: String
    let latitude: Double
    let longitude: Double
}










