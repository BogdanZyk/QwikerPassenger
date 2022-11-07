//
//  MapHelpers.swift
//  Qwiker
//
//  Created by Bogdan Zykov on 01.11.2022.
//

import MapKit

final class MapHelpers{
    
    
    static func ridePriceAndDestinceForType(_ type: RideType, currentLocation: AppLocation?, destinationLocation: AppLocation?) -> (price: Double, tripDistanceInMeters: Double)  {
        guard let currentLocation = currentLocation, let destinationLocation = destinationLocation else { return (0.0, 0.0) }
        let location = CLLocation(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        let tripDistanceInMeters = location.distance(from: CLLocation(latitude: destinationLocation.coordinate.latitude, longitude: destinationLocation.coordinate.longitude))
        
        let price = type.price(for: tripDistanceInMeters)
        
        return (price, tripDistanceInMeters)
    }
    
    static func getDestinationRoute(from userLocation: CLLocationCoordinate2D,
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
