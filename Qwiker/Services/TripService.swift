//
//  TripService.swift
//  Qwiker
//
//  Created by Богдан Зыков on 27.10.2022.
//

import Firebase
import Foundation

typealias FirestoreCompletion = (((Error?) -> Void)?)

struct TripService {
    
    // MARK: - Properties
    
    var trip: RequestedTrip?
    var user: User?
    
    // MARK: - Helpers
    
   func updateTripState(_ trip: RequestedTrip, state: TripState, completion: FirestoreCompletion) {
       FbConstant.COLLECTION_RIDES.document(trip.tripId).updateData(["tripState": state.rawValue], completion: completion)
    }
    
    func deleteTrip(completion: FirestoreCompletion) {
        guard let trip = trip else { return }
        FbConstant.COLLECTION_RIDES.document(trip.tripId).delete(completion: completion)
    }
}


// MARK: - Passenger API
extension TripService {
    func addTripObserverForPassanger(listener: @escaping(FIRQuerySnapshotBlock)) {
        guard let user = user, let uid = user.id else { return }
        FbConstant.COLLECTION_RIDES.whereField("passengerUid", isEqualTo: uid).addSnapshotListener(listener)
    }
}


//// MARK: - Driver API
//extension TripService {
//    
//    func addTripObserverForDriver(listener: @escaping(FIRQuerySnapshotBlock)) {
//        guard let user = user, user.accountType == .driver, let uid = user.id else { return }
//        FbConstant.COLLECTION_RIDES.whereField("driverUid", isEqualTo: uid).addSnapshotListener(listener)
//    }
//
//    func acceptTrip(completion: FirestoreCompletion) {
//        guard let trip = trip else { return }
//        guard let user = user, user.accountType == .driver else { return }
//
//        FbConstant.COLLECTION_RIDES.document(trip.tripId).updateData(["tripState": MapViewState.tripAccepted.rawValue], completion: completion)
//    }
//}
