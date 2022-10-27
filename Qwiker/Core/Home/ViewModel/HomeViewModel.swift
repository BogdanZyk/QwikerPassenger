//
//  HomeViewModel.swift
//  Qwiker
//
//  Created by Богдан Зыков on 27.10.2022.
//

import Foundation
import CoreLocation
import GeoFireUtils
import FirebaseFirestore
import FirebaseFirestoreSwift
import Firebase
import SwiftUI



final class HomeViewModel: ObservableObject{
    
    @Published var drivers = [User]()
    @Published var trip: Trip?
    @Published var mapState = MapViewState.noInput
    @Published var pickupTime: String?
    @Published var dropOffTime: String?
    @Published var user: User?
    
    
    
    
    
    
    
    
    
    
    
    func getDestinationRoute(from userLocation: CLLocationCoordinate2D,
                             to destinationCoordinate: CLLocationCoordinate2D,
                             completion: @escaping(MKRoute) -> Void) {
        let userPlacemark = MKPlacemark(coordinate: userLocation)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: userPlacemark)
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationCoordinate))
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        
        
        directions.calculate { response, error in
            if let error = error {
                print("DEBUG: Failed to generate polyline with error \(error.localizedDescription)")
                return
            }
            
            guard let route = response?.routes.first else { return }
            completion(route)
        }
    }
}
