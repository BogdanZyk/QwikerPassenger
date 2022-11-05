//
//  DriverAnnotation.swift
//  Qwiker
//
//  Created by Богдан Зыков on 28.10.2022.
//

import MapKit


class DriverAnnotation: NSObject, MKAnnotation {
    @objc dynamic var coordinate: CLLocationCoordinate2D
    var uid: String
    var course: Double
    
    init(uid: String, course: Double, coordinate: CLLocationCoordinate2D) {
        self.uid = uid
        self.course = course
        self.coordinate = coordinate
    }
    
    func updatePosition(withCoordinate coordinate: CLLocationCoordinate2D) {
        UIView.animate(withDuration: 0.2) {
            self.coordinate = coordinate
        }
    }
    
}
