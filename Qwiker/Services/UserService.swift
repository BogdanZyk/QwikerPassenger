//
//  UserService.swift
//  Qwiker
//
//  Created by Богдан Зыков on 27.10.2022.
//

import Firebase
import FirebaseFirestore

struct UserService {
    
    static func fetchUser(withUid uid: String, completion: @escaping(User?, Error?) -> Void) {
        
        FbConstant.COLLECTION_USERS.document(uid).getDocument { snapshot, error in
          
            if let error = error{
                completion(nil, error)
            }else{
                let user = try? snapshot?.data(as: User.self)
                completion(user, nil)
            }
        }
    }
    
    static func createUserModel(withName name: String = "", email: String = "", phone: String) -> User? {
        guard let userLocation = LocationManager.shared.userLocation else { return nil }
        
        let user = User(
            fullname: name,
            email: email,
            phoneNumber: phone,
            coordinates: GeoPoint(latitude: userLocation.coordinate.latitude,
                                  longitude: userLocation.coordinate.longitude))
        return user
    }
    
    static func uploadUserData(withUid uid: String, user: User, completion: @escaping (Error?) -> Void) {
        guard let encodedUser = try? Firestore.Encoder().encode(user) else { return }
        
        FbConstant.COLLECTION_USERS.document(uid).setData(encodedUser) { error in
            if let error = error{
                completion(error)
                return
            }
            completion(nil)
        }
    }
}
