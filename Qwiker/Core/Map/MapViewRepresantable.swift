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
            context.coordinator.removeUnActiveDrivers(homeViewModel.drivers)
        case .locationSelected:
            context.coordinator.addAnnotationAndGeneratePolyline()
        case .tripAccepted:
            context.coordinator.configureMapForTrip()
            context.coordinator.updateDriverPositionAndOverlayForTripState()
        case .tripInProgress:
            context.coordinator.updateDriverPositionAndOverlayForTripState()
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
        var didSetVisibleMapRectForTrip = false
        var acceptDriverCoordinate: CLLocationCoordinate2D?
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
                let image = UIImage(named: "car-top-view")?.imageResize(sizeChange: CGSize.init(width: 25, height: 40))
                view.image = image
                view.transform = .init(rotationAngle: 0)
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
        
        //trip in accept
        func addAnnotationAndGeneratePolylineToPassenger(_ driverCoordinate: CLLocationCoordinate2D) {
            guard let trip = parent.homeViewModel.trip, let savedDriverCoordinate = acceptDriverCoordinate else { return }
            addAndSelectAnnotation(withCoordinate: trip.pickupLocationCoordiantes, anno: MKPointAnnotation())
            
            if driverCoordinate != savedDriverCoordinate{
                parent.mapView.removeOverlays(parent.mapView.overlays)
                self.configurePolyline(currentLocation: driverCoordinate, withDestinationCoordinate: trip.pickupLocationCoordiantes)
            }
        }
        
        //trip in progress
        func addAnnotationAndGeneratePolylineToDestination(_ driverCoordinate: CLLocationCoordinate2D){
            guard let trip = parent.homeViewModel.trip, let savedDriverCoordinate = acceptDriverCoordinate else { return }
            addAndSelectAnnotation(withCoordinate: trip.dropoffLocationCoordinates, anno: MKPointAnnotation())
            if driverCoordinate != savedDriverCoordinate{
                parent.mapView.removeOverlays(parent.mapView.overlays)
                self.configurePolyline(currentLocation: driverCoordinate, withDestinationCoordinate: trip.dropoffLocationCoordinates)
            }
        }
        
        
        func configureMapForTrip() {
            guard let trip = parent.homeViewModel.trip else { return }
            if !didSetVisibleMapRectForTrip {
                var driverAnnotations = parent.mapView.annotations.filter({ $0.isKind(of: DriverAnnotation.self) }) as! [DriverAnnotation]
                driverAnnotations.removeAll(where: {$0.uid == trip.driverUid})
                removeAnnotationsAndOverlays(driverAnnotations)
            }
            
            didSetVisibleMapRectForTrip = true
        }
        
        func updateDriverPositionAndOverlayForTripState() {
            guard let trip = parent.homeViewModel.trip,  let tripDriver = parent.homeViewModel.drivers.first(where: { $0.uid == trip.driverUid }) else { return }
            let driverCoordinates = CLLocationCoordinate2D(latitude: tripDriver.coordinates.latitude,longitude: tripDriver.coordinates.longitude)
           
            let driverAnnotations = parent.mapView.annotations.filter({ $0.isKind(of: DriverAnnotation.self) }) as? [DriverAnnotation]
            
            if let driverAnno = driverAnnotations?.first(where: { $0.uid == trip.driverUid }){
                driverAnno.updatePosition(withCoordinate: driverCoordinates)
                self.updateAngleForAnnotation(driverAnno, course: tripDriver.course)
            }else{
                let annotation = DriverAnnotation(uid: tripDriver.uid, course: tripDriver.course, coordinate:
                driverCoordinates)
                parent.mapView.addAnnotation(annotation)
            }
            
            //update overlays
            if parent.homeViewModel.mapState == .tripAccepted{
                addAnnotationAndGeneratePolylineToPassenger(driverCoordinates)
            }else if parent.homeViewModel.mapState == .tripInProgress{
                addAnnotationAndGeneratePolylineToDestination(driverCoordinates)
            }
    
            self.acceptDriverCoordinate = driverCoordinates
        }

        func configurePolyline(currentLocation: CLLocationCoordinate2D?,  withDestinationCoordinate coordinate: CLLocationCoordinate2D) {
            guard let currentLocation = currentLocation, parent.mapView.overlays.isEmpty else { return }
            parent.homeViewModel.getDestinationRoute(from: currentLocation, to: coordinate) {route in
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
                let annotation = DriverAnnotation(uid: driver.uid, course: driver.course, coordinate: driverCoordinate)
                
                var driverIsVisible: Bool {
                    return self.parent.mapView.annotations.contains(where: { annotation -> Bool in
                        guard let driverAnno = annotation as? DriverAnnotation else { return false }
                        if driverAnno.uid == driver.id ?? "" {
                            driverAnno.updatePosition(withCoordinate: driverCoordinate)
                            self.updateAngleForAnnotation(driverAnno, course: driver.course)
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
        func removeUnActiveDrivers(_ drivers: [Rider]){
            let annotations = parent.mapView.annotations.filter({ $0.isKind(of: DriverAnnotation.self)})
            drivers.forEach { driver in
                annotations.forEach { anno in
                    guard let driverAnno = anno as? DriverAnnotation else { return }
                    if driverAnno.uid == driver.uid && !driver.isActive{
                        parent.mapView.removeAnnotation(driverAnno)
                    }
                }
            }
        }
        
        func updateAngleForAnnotation(_ anno: MKAnnotation, course: Double){
            let annotationView = parent.mapView.view(for: anno)
            annotationView?.rotate(degrees: course)
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








extension UIView {


    func rotate(degrees: CGFloat) {

        let degreesToRadians: (CGFloat) -> CGFloat = { (degrees: CGFloat) in
            return degrees / 180.0 * CGFloat.pi
        }
        self.transform =  CGAffineTransform(rotationAngle: degreesToRadians(degrees))
    }
}
