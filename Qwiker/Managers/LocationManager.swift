//
//  LocationManager.swift
//  Qwiker
//
//  Created by Богдан Зыков on 27.10.2022.
//



import CoreLocation
import MapKit
import SwiftUI

let SPAN = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)

class LocationManager: NSObject, ObservableObject{
    
    static let shared = LocationManager()
    
    var mapView: MKMapView?
    var currentRect: MKMapRect?
    
    private let locationManager = CLLocationManager()
    @Published var showAlert: Bool = false
    @Published var isAuthorization: Bool = false
    @Published var userLocation: CLLocation?
    
    @AppStorage("isShowOnboarding") var isShowOnboarding: Bool = true
    
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        requestStatus()
    }
    
    //MARK: - Request
    func requestLocation(){
        locationManager.requestWhenInUseAuthorization()
        requestStatus()
    }
    
    func requestStatus(){
       switch locationManager.authorizationStatus{
       case .authorizedAlways, .authorizedWhenInUse:
           locationManager.startUpdatingLocation()
           isAuthorization = true
           print("isAuthorization1", isAuthorization)
       case .denied, .restricted:
           print("denied", "restricted")
           showAlert = true
       case .notDetermined:
           if !isShowOnboarding{
               locationManager.requestWhenInUseAuthorization()
           }
       default:
           break
       }
    }
    
    //MARK: - Map helpers
    
    func setUserLocationInMap(){
        guard let userLocation = userLocation else {return}
        let region = MKCoordinateRegion(center: userLocation.coordinate, span: SPAN)
        mapView?.setRegion(region, animated: true)
    }
    
    func setCurrentRectInMap(){
        guard let currentRect = currentRect else {return}
        mapView?.setRegion(MKCoordinateRegion(currentRect), animated: true)
    }
    
    func updateRegion(_ updatedRegion: MKCoordinateRegion?){
        if let region = updatedRegion{
            mapView?.setRegion(region, animated: true)
            print("UPDATE", region)
        }
    }
}


extension LocationManager: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {return}
        userLocation = location
        locationManager.stopUpdatingLocation()
    }
    
    
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {

        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            print("denied", "restricted")
            showAlert = true
            userLocation = nil
        default:
            showAlert.toggle()
            userLocation = nil
        }
    }
}
