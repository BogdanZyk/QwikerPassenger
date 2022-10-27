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
    @Published var mapState = MapViewState.noInput
    
}
