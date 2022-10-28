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
    @Binding var mapState: MapViewState
    
    init(mapState: Binding<MapViewState>) {
        self._mapState = mapState
    }
    
    // MARK: - Protocol Functions
    
    func makeUIView(context: Context) -> MKMapView {
        mapView.isRotateEnabled = false
        mapView.showsUserLocation = true
        mapView.delegate = context.coordinator
        locationManager.mapView = mapView
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        switch mapState {
        case .noInput:
            context.coordinator.clearMapView()
            context.coordinator.addDriversToMapAndUpdateLocation(homeViewModel.drivers)
        case .locationSelected:
            context.coordinator.addAnnotationAndGeneratePolyline()
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
            print("CHANGE REGION")
            if parent.mapState == .noInput{
                DispatchQueue.main.async(qos: .userInitiated) {
                    self.parent.searchViewModel.updatedRegion = mapView.region
                }
                currentLocation = mapView.region.center
            }
        }
        
        func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
            DispatchQueue.main.async(qos: .userInitiated) {
                withAnimation {
                    self.parent.searchViewModel.isAnimatePin = true
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
            addAndSelectAnnotation(withCoordinate: currenCoordinate, anno: currentAnno)
            addAndSelectAnnotation(withCoordinate: destinationCoordinate, anno: destinationAnno)
            configurePolyline(withDestinationCoordinate: destinationCoordinate)
        }
        
        func addAndSelectAnnotation(withCoordinate coordinate: CLLocationCoordinate2D, anno: MKAnnotation){
            self.parent.mapView.addAnnotation(anno)
            self.parent.mapView.selectAnnotation(anno, animated: true)
        }

        func configurePolyline(withDestinationCoordinate coordinate: CLLocationCoordinate2D) {
            guard let currentLocation = currentLocation else { return }
            
            parent.homeViewModel.getDestinationRoute(from: currentLocation, to: coordinate) { route in
                self.parent.mapState = .polylineAdded
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
            let annotations = parent.mapView.annotations.filter({ !$0.isKind(of: DriverAnnotation.self) })
            guard !parent.mapView.overlays.isEmpty, !annotations.isEmpty else { return }
            removeAnnotationsAndOverlays(annotations)
            if let currentRegion = currentRegion{
                parent.mapView.setRegion(currentRegion, animated: true)
            }
        }
        
        func removeAnnotationsAndOverlays(_ annotations: [MKAnnotation]) {
            parent.mapView.removeAnnotations(annotations)
            parent.mapView.removeOverlays(parent.mapView.overlays)
        }
    }
}








