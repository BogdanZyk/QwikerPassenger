//
//  Preview.swift
//  Qwiker
//
//  Created by Богдан Зыков on 27.10.2022.
//

import SwiftUI
import MapKit
import Firebase

extension PreviewProvider {
    
    static var dev: DeveloperPreview {
        return DeveloperPreview.instance
    }
}
/*
 let driverName: String
 let passengerName: String
 let driverImageUrl: String
 let passengerImageUrl: String?*/

class DeveloperPreview {
    static let instance = DeveloperPreview()
    
    let mockSelectedLocation = AppLocation(title: "Starbucks", coordinate: CLLocationCoordinate2D(latitude: 37.6, longitude: -122.43))
    
    let mockTrip = Trip(driverUid: NSUUID().uuidString,
                        passengerUid: NSUUID().uuidString,
                        pickupLocation: GeoPoint(latitude: 37.6, longitude: -122.43),
                        dropoffLocation: GeoPoint(latitude: 37.55, longitude: -122.4),
                        driverLocation: GeoPoint(latitude: 37.4, longitude: -122.1),
                        dropoffLocationName: "Starbucks",
                        pickupLocationName: "Apple Campus",
                        pickupLocationAddress: "123 Main st",
                        tripCost: 40.00,
                        tripState: .inProgress,
                        driverName: "John Smith",
                        passengerName: "Stephan Dowless",
                        driverImageUrl: "",
                        passengerImageUrl: "")
    
    let userLocation = CLLocation(latitude: 37.75, longitude: -122.432)
    
//    let rideDetails = RideDetails(startLocation: "Current Location",
//                                  endLocation: "123 Main St",
//                                  userLocation: CLLocation(latitude: 37.75, longitude: -122.432))
    
    let mockPassenger = User(id: NSUUID().uuidString,
                             fullname: "Stephan Dowless",
                             email: "test@gmail.com",
                             phoneNumber: "78005553535",
                             profileImageUrl: nil,
                             homeLocation: nil,
                             workLocation: nil,
                             accountType: .passenger,
                             coordinates: GeoPoint(latitude: 37.4, longitude: -122.1),
                             isActive: true)
    
    let mockDriver = User(id: NSUUID().uuidString,
                          fullname: "John Doe",
                          email: "johndoe@gmail.com",
                          phoneNumber: "78005553535",
                          profileImageUrl: nil,
                          homeLocation: nil,
                          workLocation: nil,
                          accountType: .driver,
                          coordinates: GeoPoint(latitude: 37.41, longitude: -122.1),
                          isActive: false)
    
    var homeViewModel: HomeViewModel {
        let vm = HomeViewModel()
        vm.trip = mockTrip
        vm.user = mockDriver
        //vm.selectedLocation = mockSelectedLocation
        return vm
    }
}