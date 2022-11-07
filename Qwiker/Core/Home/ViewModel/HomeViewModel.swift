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
    @Published var trip: RequestedTrip?
    @Published var mapState = MapViewState.noInput
    @Published var pickupTime: String?
    @Published var dropOffTime: String?
    @Published var user: User?
    @Published var currentRoute: MKRoute?
    @Published var selectedRideType: RideType = .economy
    @Published var isShowCompletedSheet: Bool = false
    var didExecuteFetchDrivers = false
    var userLocation: AppLocation?
    var selectedLocation: AppLocation?
    
    private let radius: Double = 800
    private var driverQueue = [Rider]()
    
    private var tripService = TripService()
    private var ridePrice = 0.0
    private var listenersDictionary = [String: ListenerRegistration]()
    private var tripDistanceInMeters = 0.0
    
    
    
    
    
    // MARK: - Lifecycle
    
    init() {
        fetchUser()
    }

    
    //MARK: - Home View for state logic
    var isShowMainActionButton: Bool{
        switch mapState {
        case .tripRequested, .tripAccepted, .driverArrived, .tripInProgress,
                .arrivedAtDestination, .tripCompleted, .tripCancelled:
            return false
        default:
            return true
        }
    }


}

//MARK: - Map Helpers

extension HomeViewModel {
    
    private func reset() {
        selectedLocation = nil
        trip = nil
        mapState = .noInput
        setCurrentUserRegion()
    }
    
    func setCurrentUserRegion(){
        LocationManager.shared.setUserLocationInMap()
    }
    
    func getDestinationRoute(from userLocation: CLLocationCoordinate2D,
                             to destinationCoordinate: CLLocationCoordinate2D,
                             completion: @escaping(MKRoute) -> Void) {
        MapHelpers.getDestinationRoute(from: userLocation, to: destinationCoordinate) {[weak self] route in
            guard let self = self else {return}
            self.configurePickupAndDropOffTime(with: route.expectedTravelTime)
            self.currentRoute = route
            completion(route)
        }
    }
    
    func configurePickupAndDropOffTime(with expectedTravelTime: Double) {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        
        pickupTime = formatter.string(from: Date())
        dropOffTime = formatter.string(from: Date() + expectedTravelTime)
    }
    
    func ridePriceForType(_ type: RideType) -> Double {
       let distanceAndPrice =  MapHelpers.ridePriceAndDestinceForType(type, currentLocation: userLocation, destinationLocation: selectedLocation)
        self.tripDistanceInMeters = distanceAndPrice.tripDistanceInMeters
        return distanceAndPrice.price
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
    
    private func updateTripState(_ trip: RequestedTrip, state: TripState, completion: ((Error?) -> Void)?) {
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
        tripService.addTripObserverForPassanger {[weak self] snapshot, error in
            guard let self = self else {return}
            guard let change = snapshot?.documentChanges.first, change.type == .added || change.type == .modified else { return }
            switch change.type {
            case .added, .modified:
                guard let trip = try? change.document.data(as: RequestedTrip.self) else { return }
                self.trip = trip
                self.tripService.trip = trip
                
                if self.selectedLocation == nil {
                    self.selectedLocation = AppLocation(title: trip.dropoffLocationName, coordinate: trip.dropoffLocationCoordinates)
                }
                withAnimation {
                    self.updateViewStateForTrip(trip)
                }
                
            case .removed:
                print("DEBUG: Trip cancelled by driver")
                //TODO: Show notification to passenger that trip was cancelled
                self.mapState = .noInput
            }
        }
    }
    
    private func updateViewStateForTrip(_ trip: RequestedTrip){
        switch trip.tripState {
        case .rejectedByDriver:
            self.requestRide()
        case .accepted:
            self.mapState = .tripAccepted
        case .driverArrived:
            self.mapState = .driverArrived
        case .inProgress:
            self.mapState = .tripInProgress
        case .arrivedAtDestination:
            self.mapState = .arrivedAtDestination
        case .complete:
            self.reset()
            self.isShowCompletedSheet.toggle()
        case .cancelled:
            self.mapState = .noInput
        case .requested:
            self.mapState = .tripRequested
        default:
            break
        }
    }
    
    //MARK: - Request ride for driverQueue
    
    func requestRide() {
        ridePrice = ridePriceForType(selectedRideType)
        print("DEBUG", driverQueue.count)
        if driverQueue.isEmpty {
            //guard let trip = trip else { return }
            //updateTripState(trip, state: .rejectedByAllDrivers) { _ in
                self.deleteTrip()
                self.reset()
            //}
        } else {
            print("DEBUG", driverQueue.compactMap({$0.isActive}))
            let driver = driverQueue.removeFirst()
            print("DEBUG", driver.fullname)
            sendRideRequestToDriver(driver)
        }
    }
    
    func cancelTrip() {
        guard let trip = trip else { return }
        
        updateTripState(trip, state: .cancelled) { _ in
            self.reset()
        }
    }
    
    func cancelSearchTrip(){
        deleteTrip()
        self.reset()
    }
    
    private func sendRideRequestToDriver(_ driver: Rider) {
        guard let user = user, let currentUid = user.id else { return }
        guard let driverUid = driver.id, driver.isActive else { return }
        guard let userLocation = userLocation, let selectedLocation = selectedLocation else { return }
        if let trip = trip, trip.tripState != .cancelled, trip.tripState != .complete {
            let updatedData: [String: Any] = [
                "tripState": TripState.requested.rawValue,
                "driverUid": driverUid
            ]
            FbConstant.COLLECTION_RIDES.document(trip.tripId).updateData(updatedData) { error in
                print("DEBUG: Updated trip data..")
            }
        } else {
            let pickupGeoPoint = GeoPoint(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
            let dropoffGeoPoint = GeoPoint(latitude: selectedLocation.coordinate.latitude, longitude: selectedLocation.coordinate.longitude)
            let driverGeoPoint = GeoPoint(latitude: driver.coordinates.latitude, longitude: driver.coordinates.longitude)
            
            let trip = RequestedTrip(driverUid: driverUid,
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
                            passengerImageUrl: user.profileImageUrl,
                            carModel: driver.vehicle?.model,
                            carNumber: driver.vehicle?.number,
                            carColor: driver.vehicle?.color.description)
            
            guard let encodedTrip = try? Firestore.Encoder().encode(trip) else { return }
            
            FbConstant.COLLECTION_RIDES.document().setData(encodedTrip)
        }
    }
    
    //TODO: Extract to PassengerService
    func fetchNearbyDrivers(withCoordinates coordinates: CLLocationCoordinate2D) {
        print("DEBUG", "fetchNearbyDrivers")
        drivers.removeAll()
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
                if !(drivers.contains(where: {$0.id == driver.id})){
                    drivers.append(driver)
                }
            }
        }
        
        self.drivers.append(contentsOf: drivers)
        self.driverQueue = self.drivers.filter({$0.isActive})
        self.addListenerToDrivers()
        print("DEBUG:", self.drivers.compactMap({$0.fullname}))
    }
    
    func addListenerToDrivers() {
        guard !drivers.isEmpty else {return}
        for i in 0 ..< drivers.count {
            
            let driver = drivers[i]
            
            let driverListener = FbConstant.COLLECTION_DRIVERS.document(driver.id ?? "").addSnapshotListener { snapshot, error in
                guard let driver = try? snapshot?.data(as: Rider.self), let index = self.drivers.firstIndex(where: {$0.uid == driver.uid}) else {return}
                
                self.drivers[index].isActive = driver.isActive
                self.drivers[index].coordinates = driver.coordinates
                if !driver.isActive{
                    self.driverQueue.removeAll(where: {$0.uid == driver.uid})
                }
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
    
    


}




