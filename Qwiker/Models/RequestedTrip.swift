//
//  RequestedTrip.swift
//  Qwiker
//
//  Created by Богдан Зыков on 27.10.2022.
//

import Foundation
import FirebaseFirestoreSwift
import Firebase
import CoreLocation


struct RequestedTrip: Codable, Identifiable{
    
    @DocumentID var id: String?
    let driverUid: String
    let passengerUid: String
    let pickupLocation: GeoPoint
    let dropoffLocation: GeoPoint
    var driverLocation: GeoPoint?
    let dropoffLocationName: String
    let pickupLocationName: String
    let pickupLocationAddress: String
    let tripCost: Double
    let tripState: TripState
    let driverName: String
    let passengerName: String
    let driverImageUrl: String
    let passengerImageUrl: String?
    let carModel: String?
    let carNumber: String?
    let carColor: String?
    
    var tripId: String { return id ?? "" }
    
    var dropoffLocationCoordinates: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: dropoffLocation.latitude, longitude: dropoffLocation.longitude)
    }
    
    var pickupLocationCoordiantes: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: pickupLocation.latitude, longitude: pickupLocation.longitude)
    }
    
    var dropoffAppLocation: AppLocation {
        return AppLocation(title: dropoffLocationName, coordinate: dropoffLocationCoordinates)
    }
    
    var passengerFirstNameUppercased: String {
        let components = passengerName.components(separatedBy: " ")
        guard let firstName = components.first else { return passengerName.uppercased() }
        
        return firstName.uppercased()
    }
    
    var driverFirstName: String {
        let components = driverName.components(separatedBy: " ")
        guard let firstName = components.first else { return driverName}
        
        return firstName
    }
    
    var carInfo: String{
        (carColor ?? "Color") + " " + (carModel ?? "Model")
    }
}



enum TripState: Int, Codable{
    case driversUnavailable
    case rejectedByDriver
    case rejectedByAllDrivers
    case requested // value has to equal 3 to correspond to mapView tripRequested state
    case accepted
    case driverArrived
    case inProgress
    case arrivedAtDestination
    case complete
    case cancelled
}
