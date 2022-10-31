//
//  MapViewRepresantable.swift
//  Qwiker
//
//  Created by Богдан Зыков on 27.10.2022.
//
import MapKit
import SwiftUI

struct MapViewRepresentable: UIViewRepresentable {
    
    let mapView = MKMapView()
    var locationManager = LocationManager.shared
    @EnvironmentObject var searchViewModel: SearchViewModel
    @EnvironmentObject var homeViewModel: HomeViewModel
    
    // MARK: - Protocol Functions
    
    func makeUIView(context: Context) -> MKMapView {
        mapView.isRotateEnabled = false
        mapView.showsUserLocation = true
        mapView.delegate = context.coordinator
        locationManager.mapView = mapView
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        switch homeViewModel.mapState {
        case .noInput:
            context.coordinator.clearMapView()
            context.coordinator.addDriversToMapAndUpdateLocation(homeViewModel.drivers)
        case .locationSelected:
            context.coordinator.addAnnotationAndGeneratePolyline()
        case .tripAccepted:
            guard let trip = homeViewModel.trip else { return }
            context.coordinator.configureMapForTrip(trip)
            context.coordinator.updateDriverPositionForTrip(trip)
        default:
            break
        }
    }
    
    func makeCoordinator() -> MapCoordinator {
        .init(parent: self)
    }
    
}

extension MapViewRepresentable {

    class MapCoordinator: NSObject, MKMapViewDelegate {
        
        // MARK: - Properties
        
        let parent: MapViewRepresentable
        var userLocation: MKUserLocation?
        var currentLocation: CLLocationCoordinate2D?
        var currentRegion: MKCoordinateRegion?
        var didSetVisibleMapRectForTrip = false
        // MARK: - Lifecycle
        
        init(parent: MapViewRepresentable) {
            self.parent = parent
            super.init()
        }
        
        // MARK: - MKMapViewDelegate
        func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
            guard userLocation != self.userLocation else {return}
            self.userLocation = userLocation
            let region = MKCoordinateRegion(
                center: userLocation.coordinate,
                span: SPAN
            )
            self.currentRegion = region
            parent.mapView.setRegion(region, animated: true)
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let over = MKPolylineRenderer(overlay: overlay)
            over.strokeColor = UIColor(named: "primaryBlue")
            over.lineWidth = 6
            return over
        }
        
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            if parent.homeViewModel.mapState == .noInput{
                print("CHANGE REGION")
                DispatchQueue.main.async(qos: .userInitiated) {
                    self.parent.searchViewModel.updatedRegion = mapView.region
                    self.currentLocation = mapView.region.center
                }
                print("DEBUG", currentLocation)
            }
        }
        
        func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
            if parent.homeViewModel.mapState == .noInput{
                DispatchQueue.main.async(qos: .userInitiated) {
                    withAnimation {
                        self.parent.searchViewModel.isAnimatePin = true
                    }
                }
            }
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
           
            if let destinationAnno = annotation as? MKPointAnnotation{
                let customAnnotationView = self.customAnnotationView(in: mapView, for: destinationAnno)
                return customAnnotationView
            }
            
            if let currentAnno = annotation as? CurrentAnnotation {
                let view = MKAnnotationView(annotation: currentAnno, reuseIdentifier: "currentAnno")
                view.addSubview(self.customAnnotationView(in: mapView, for: currentAnno, isCurrent: true))
                return view
            }
            
            if let annotation = annotation as? DriverAnnotation {
                let view = MKAnnotationView(annotation: annotation, reuseIdentifier: "driver")
                let image = UIImage(named: "car-top-view")?.imageResize(sizeChange: CGSize.init(width: 40, height: 30))
                view.image = image
                return view
            }
            
            return nil
        }
        
        private func customAnnotationView(in mapView: MKMapView, for annotation: MKAnnotation, isCurrent: Bool = false) -> CustomLocationAnnotationView {
            let identifier = isCurrent ? "CurrentAnnotationAnno" : "DestinationAnnotationAnno"

            if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? CustomLocationAnnotationView {
                annotationView.annotation = annotation
                annotationView.isCurrent = isCurrent
                return annotationView
            } else {
                let customAnnotationView = CustomLocationAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                customAnnotationView.canShowCallout = true
                customAnnotationView.isCurrent = isCurrent
                return customAnnotationView
            }
        }
        
        //MARK: Helpers
        
        func addAnnotationAndGeneratePolyline() {
            guard let destinationCoordinate = parent.searchViewModel.destinationAppLocation?.coordinate, let currenCoordinate = currentLocation else { return }
            let currentAnno = CurrentAnnotation(coordinate: currenCoordinate)
            let destinationAnno = MKPointAnnotation()
            destinationAnno.coordinate = destinationCoordinate
            parent.mapView.addAnnotations([currentAnno, destinationAnno])
            configurePolyline(currentLocation: currenCoordinate, withDestinationCoordinate: destinationCoordinate)
        }
        
        func addAndSelectAnnotation(withCoordinate coordinate: CLLocationCoordinate2D, anno: MKAnnotation){
            self.parent.mapView.addAnnotation(anno)
            self.parent.mapView.selectAnnotation(anno, animated: true)
        }
        
        func addAnnotationAndGeneratePolylineToPassenger() {
            guard let trip = parent.homeViewModel.trip else { return }
            addAndSelectAnnotation(withCoordinate: trip.pickupLocationCoordiantes, anno: MKPointAnnotation())
            guard let latitude = trip.driverLocation?.latitude, let longitude = trip.driverLocation?.longitude else {return}
            let driverLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            print("DEBAG driverLocation", driverLocation)
            print("DEBAG pickupLocationCoordiantes", trip.pickupLocationCoordiantes)
            self.configurePolyline(currentLocation: driverLocation, withDestinationCoordinate: trip.pickupLocationCoordiantes)
        }
        
        
        func configureMapForTrip(_ trip: Trip) {
            if !didSetVisibleMapRectForTrip {
                var driverAnnotations = parent.mapView.annotations.filter({ $0.isKind(of: DriverAnnotation.self) }) as! [DriverAnnotation]
                driverAnnotations.removeAll(where: {$0.uid == trip.driverUid})
                removeAnnotationsAndOverlays(driverAnnotations)
            }
            addAnnotationAndGeneratePolylineToPassenger()
            didSetVisibleMapRectForTrip = true
        }
        
        func updateDriverPositionForTrip(_ trip: Trip) {
            guard let tripDriver = parent.homeViewModel.drivers.first(where: { $0.uid == trip.driverUid }) else { return }
            let driverCoordinates = CLLocationCoordinate2D(latitude: tripDriver.coordinates.latitude,longitude: tripDriver.coordinates.longitude)
            let driverAnnotations = parent.mapView.annotations.filter({ $0.isKind(of: DriverAnnotation.self) }) as? [DriverAnnotation]
            
            if let driverAnno = driverAnnotations?.first(where: { $0.uid == trip.driverUid }){
                driverAnno.updatePosition(withCoordinate: driverCoordinates)
            }else{
                let annotation = DriverAnnotation(uid: trip.driverUid, coordinate:
                driverCoordinates)
                parent.mapView.addAnnotation(annotation)
            }

        }

        func configurePolyline(currentLocation: CLLocationCoordinate2D?,  withDestinationCoordinate coordinate: CLLocationCoordinate2D) {
            guard let currentLocation = currentLocation, parent.mapView.overlays.isEmpty else { return }
            parent.homeViewModel.getDestinationRoute(from: currentLocation, to: coordinate) {route in
                print("DEBUG Add overlay")
                self.parent.mapView.addOverlay(route.polyline)
                let rect = self.parent.mapView.mapRectThatFits(route.polyline.boundingMapRect,
                                                               edgePadding: .init(top: 64, left: 32, bottom: 400, right: 32))
                self.parent.locationManager.currentRect = rect
                self.parent.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
            }
        }
        
        //MARK: - Add drivers annonatations
        
        func addDriversToMapAndUpdateLocation(_ drivers: [Rider]) {
            drivers.forEach { driver in
                let driverCoordinate = CLLocationCoordinate2D(latitude: driver.coordinates.latitude,longitude: driver.coordinates.longitude)
                let annotation = DriverAnnotation( uid: driver.id ?? NSUUID().uuidString, coordinate: driverCoordinate)
                
                var driverIsVisible: Bool {
                    return self.parent.mapView.annotations.contains(where: { annotation -> Bool in
                        guard let driverAnno = annotation as? DriverAnnotation else { return false }
                        if driverAnno.uid == driver.id ?? "" {
                            driverAnno.updatePosition(withCoordinate: driverCoordinate)
                            return true
                        }
                        return false
                    })
                }
                
                if !driverIsVisible{
                    self.parent.mapView.addAnnotation(annotation)
                }
            }
        }
        
        func clearMapView() {
            didSetVisibleMapRectForTrip = false
            let annotations = parent.mapView.annotations.filter({ !$0.isKind(of: DriverAnnotation.self) && !$0.isKind(of: MKUserLocation.self) })
            removeAnnotationsAndOverlays(annotations)
        }
        
        func removeAnnotationsAndOverlays(_ annotations: [MKAnnotation]) {
            if !annotations.isEmpty{
                parent.mapView.removeAnnotations(annotations)
            }
                
            if !parent.mapView.overlays.isEmpty{
                parent.mapView.removeOverlays(parent.mapView.overlays)
            }
            
        }
    }
}








