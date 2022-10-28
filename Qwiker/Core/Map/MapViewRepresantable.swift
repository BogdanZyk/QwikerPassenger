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
        case .searchingForLocation:
            break
        case .locationSelected:
            context.coordinator.clearMapView()
            context.coordinator.addAnnotationAndGeneratePolyline()
        case .polylineAdded:
            break
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
        var currentLocation: CLLocationCoordinate2D?
        var currentRegion: MKCoordinateRegion?
        // MARK: - Lifecycle
        
        init(parent: MapViewRepresentable) {
            self.parent = parent
            super.init()
        }
        
        // MARK: - MKMapViewDelegate
        func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
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
                                                               edgePadding: .init(top: 64, left: 32, bottom: 300, right: 32))
                self.parent.locationManager.currentRect = rect
                self.parent.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
            }
        }
        
        func clearMapView() {
            guard !parent.mapView.overlays.isEmpty, !parent.mapView.annotations.isEmpty else { return }
            removeAnnotationsAndOverlays(parent.mapView.annotations)
            if let currentRegion = currentRegion {
                parent.mapView.setRegion(currentRegion, animated: true)
            }
        }
        
        func removeAnnotationsAndOverlays(_ annotations: [MKAnnotation]) {
            parent.mapView.removeAnnotations(annotations)
            parent.mapView.removeOverlays(parent.mapView.overlays)
        }
    }
}


class CurrentAnnotation: NSObject, MKAnnotation {
    @objc dynamic var coordinate: CLLocationCoordinate2D

    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
    
    func updatePosition(withCoordinate coordinate: CLLocationCoordinate2D) {
        UIView.animate(withDuration: 0.2) {
            self.coordinate = coordinate
        }
    }
}

class CustomLocationAnnotationView: MKAnnotationView {
    var isCurrent: Bool = false
    private let annotationFrame = CGRect(x: 0, y: 0, width: 20, height: 20)
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.frame = annotationFrame
        self.backgroundColor = .clear
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented!")
    }

    override func draw(_ rect: CGRect) {
        if isCurrent{
            UIColor.black.setFill()
            let outerPath = UIBezierPath(ovalIn: rect)
            outerPath.fill()
            UIColor.white.setFill()
            let centerPath = UIBezierPath(ovalIn: CGRect(x: 6, y: 6, width: 8, height: 8))
            centerPath.fill()
        }else{
            let rectangle = UIBezierPath(rect: rect)
            UIColor.black.setFill()
            rectangle.fill()
        }
    }
}

