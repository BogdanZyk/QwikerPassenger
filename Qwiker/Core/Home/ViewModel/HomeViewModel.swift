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
    
    @Published var drivers = [Rider]()
    @Published var trip: Trip?
    @Published var mapState = MapViewState.noInput
    @Published var pickupTime: String?
    @Published var dropOffTime: String?
    @Published var user: User?
    
    var didExecuteFetchDrivers = false
    var userLocation: AppLocation?
    var selectedLocation: AppLocation?
    
    private let radius: Double = 800
    private var driverQueue = [Rider]()
    
    private var tripService = TripService()
    private var ridePrice = 0.0
    private var listenersDictionary = [String: ListenerRegistration]()
    private var tripDistanceInMeters = 0.0
    private var selectedRideType: RideType = .economy
    
    
    
    
    // MARK: - Lifecycle
    
    init() {
        fetchUser()
        //addRider()
    }

    
    
    
    

}

//MARK: - Map Helpers

extension HomeViewModel {
    
    private func reset() {
        mapState = .noInput
        selectedLocation = nil
        trip = nil
    }
    
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
            self.configurePickupAndDropOffTime(with: route.expectedTravelTime)
            completion(route)
        }
    }
    
    func configurePickupAndDropOffTime(with expectedTravelTime: Double) {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        
        pickupTime = formatter.string(from: Date())
        dropOffTime = formatter.string(from: Date() + expectedTravelTime)
    }
    
    func ridePriceForType(_ type: RideType) -> String {
        guard let selectedLocation = selectedLocation, let userCoordinates = userLocation else { return "0.0" }
        let userLocation = CLLocation(latitude: userCoordinates.coordinate.latitude, longitude: userCoordinates.coordinate.longitude)
        self.tripDistanceInMeters = userLocation.distance(from: CLLocation(latitude: selectedLocation.coordinate.latitude, longitude: selectedLocation.coordinate.longitude))
        
        return type.price(for: tripDistanceInMeters).formatted(.currency(code: "USD"))
    }
    
    func createPickupAndDropoffRegionsForTrip() {
       // guard let trip = trip else { return }
//        LocationManager.shared.createPickupRegionForTrip(trip)
//        LocationManager.shared.createDropoffRegionForTrip(trip)
    }
}


// MARK: - Shared API
extension HomeViewModel {
    private func fetchUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        UserService.fetchUser(withUid: uid) {[weak self] user, error in
            guard let self = self else {return}
            if let user = user{
                self.user = user
                self.tripService.user = user
                self.addTripObserver()
            }
        }
    }
    
    private func updateTripState(_ trip: Trip, state: TripState, completion: ((Error?) -> Void)?) {
        tripService.updateTripState(trip, state: state, completion: completion)
    }

    private func deleteTrip() {
        tripService.deleteTrip { error in
            if let error = error{
                print("DEBUG: error delete trip", error.localizedDescription)
            }
        }
    }
}


// MARK: - Trip API
extension HomeViewModel {
    
    private func addTripObserver(){
        tripService.addTripObserverForPassanger { snapshot, error in
            guard let change = snapshot?.documentChanges.first, change.type == .added || change.type == .modified else { return }
            switch change.type {
            case .added, .modified:
                guard let trip = try? change.document.data(as: Trip.self) else { return }
                self.trip = trip
                self.tripService.trip = trip
                
                if self.selectedLocation == nil {
                    self.selectedLocation = AppLocation(title: trip.dropoffLocationName, coordinate: trip.dropoffLocationCoordinates)
                }
                
                switch trip.tripState {
                case .rejectedByDriver:
                    break
                    //self.requestRide(self.selectedRideType)
                case .accepted:
                    self.mapState = .tripAccepted
                case .driverArrived:
                    self.mapState = .driverArrived
                case .inProgress:
                    self.mapState = .tripInProgress
                case .arrivedAtDestination:
                    self.mapState = .arrivedAtDestination
                case .complete:
                    self.mapState = .tripCompleted
                    //self.saveCompletedTrip(trip)
                case .cancelled:
                    self.mapState = .noInput
                default:
                    break
                }
            case .removed:
                print("DEBUG: Trip cancelled by driver")
                //TODO: Show notification to passenger that trip was cancelled
                self.mapState = .noInput
            }
        }
    }
    
    func requestRide(_ rideType: RideType) {
        guard let userCoordinate = userLocation?.coordinate else { return }
        self.ridePrice = rideType.price(for: self.tripDistanceInMeters)
        
        if driverQueue.isEmpty {
            guard let trip = trip else { return }
            updateTripState(trip, state: .rejectedByAllDrivers) { _ in
                self.deleteTrip()
                self.fetchNearbyDrivers(withCoordinates: userCoordinate)
            }
        } else {
            let driver = driverQueue.removeFirst()
            sendRideRequestToDriver(driver)
        }
    }
    
    func cancelTrip() {
        guard let trip = trip else { return }
        
        updateTripState(trip, state: .cancelled) { _ in
            self.reset()
        }
    }
    
    private func sendRideRequestToDriver(_ driver: Rider) {
        guard let user = user, let currentUid = user.id else { return }
        guard let driverUid = driver.id, driver.isActive else { return }
        guard let userLocation = userLocation, let selectedLocation = selectedLocation else { return }
        
        if let trip = trip {
            let updatedData: [String: Any] = [
                "tripState": TripState.requested.rawValue,
                "driverUid": driverUid
            ]
            FbConstant.COLLECTION_RIDES.document(trip.tripId).updateData(updatedData) { _ in
                print("DEBUG: Updated trip data..")
            }
        } else {
            let pickupGeoPoint = GeoPoint(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
            let dropoffGeoPoint = GeoPoint(latitude: selectedLocation.coordinate.latitude, longitude: selectedLocation.coordinate.longitude)
            let driverGeoPoint = GeoPoint(latitude: driver.coordinates.latitude, longitude: driver.coordinates.longitude)
            
            let trip = Trip(driverUid: driverUid,
                            passengerUid: currentUid,
                            pickupLocation: pickupGeoPoint,
                            dropoffLocation: dropoffGeoPoint,
                            driverLocation: driverGeoPoint,
                            dropoffLocationName: selectedLocation.title,
                            pickupLocationName: userLocation.title,
                            pickupLocationAddress: userLocation.title,
                            tripCost: self.ridePrice,
                            tripState: .requested,
                            driverName: driver.fullname,
                            passengerName: user.fullname,
                            driverImageUrl: driver.profileImageUrl ?? "",
                            passengerImageUrl: user.profileImageUrl)
            
            guard let encodedTrip = try? Firestore.Encoder().encode(trip) else { return }
            
            FbConstant.COLLECTION_RIDES.document().setData(encodedTrip) { _ in
                self.mapState = .tripRequested
            }
        }
    }
    
    //TODO: Extract to PassengerService
    func fetchNearbyDrivers(withCoordinates coordinates: CLLocationCoordinate2D) {
        let queryBounds = GFUtils.queryBounds(forLocation: coordinates, withRadius: radius)
        didExecuteFetchDrivers = true
        
        let queries = queryBounds.map { bound -> Query in
            return FbConstant.COLLECTION_DRIVERS
                .order(by: "geohash")
                .start(at: [bound.startValue])
                .end(at: [bound.endValue])
        }
        for query in queries {
            query.getDocuments(completion: getDocumentsCompletion)
        }
    }
    
    private func getDocumentsCompletion(snapshot: QuerySnapshot?, error: Error?) -> () {
        guard let documents = snapshot?.documents else { return }
        guard let userLocation = userLocation else { return }
        var drivers = [Rider]()
        documents.forEach { doc in
            guard let driver = try? doc.data(as: Rider.self) else { return }
            let coordinates = CLLocation(latitude: driver.coordinates.latitude, longitude: driver.coordinates.longitude)
            let centerPoint = CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
            
            let distance = GFUtils.distance(from: centerPoint, to: coordinates)
            if distance <= radius {
                
                drivers.append(driver)
            }
        }
        print(drivers)
        self.drivers.append(contentsOf: drivers)
        self.driverQueue = self.drivers
        self.addListenerToDrivers()
    }
    
    func addListenerToDrivers() {
        for i in 0 ..< drivers.count {
            let driver = drivers[i]
            
            let driverListener = FbConstant.COLLECTION_DRIVERS.document(driver.id ?? "").addSnapshotListener { snapshot, error in
                guard let driver = try? snapshot?.data(as: Rider.self) else { return }
                self.drivers[i].isActive = driver.isActive
                self.drivers[i].coordinates = driver.coordinates
            }
            
            self.listenersDictionary[driver.id ?? ""] = driverListener
        }
    }
    
    
    func removeListenersFromDrivers() {
        guard let trip = trip else { return }
        
        listenersDictionary.forEach { uid, listener in
            if uid != trip.driverUid {
                listener.remove()
            }
        }
    }
    
    
//    func saveCompletedTrip(_ trip: Trip) {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        guard let encodedTrip = try? Firestore.Encoder().encode(trip) else { return }
//        FbConstant.COLLECTION_USERS
//            .document(uid)
//            .collection("user-trips")
//            .document(trip.tripId)
//            .setData(encodedTrip) { _ in
//                self.mapState = .noInput
//            }
//    }

}



//MARK: - Riders for test
extension HomeViewModel{
    private func addRider(){
        let location = CLLocationCoordinate2D(latitude: 47.228633403351864, longitude: 39.71641259567925)
        let hash = GFUtils.geoHash(forLocation: location)
        let rider = Rider(fullname: "Tester", email: "test@test.com",  phoneNumber: "88009943455", coordinates: GeoPoint(latitude: location.latitude, longitude: location.longitude), geohash: hash, isActive: true)

        guard let encodedRider = try? Firestore.Encoder().encode(rider) else { return }

        FbConstant.COLLECTION_DRIVERS.document().setData(encodedRider) { error in
            if let error = error{
                print(error)
                return
            }
            print("Rider save!")
        }
    }
}
