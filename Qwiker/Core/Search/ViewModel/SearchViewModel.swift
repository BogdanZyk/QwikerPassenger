//
//  SearchViewModel.swift
//  Qwiker
//
//  Created by Богдан Зыков on 27.10.2022.
//

import Foundation
import MapKit
import CoreLocation
import Combine

final class SearchViewModel: NSObject, ObservableObject{
    private var cancellable = Set<AnyCancellable>()
    @Published private(set) var searchResults = [MKLocalSearchCompletion]()
    @Published var currentAppLocation: AppLocation?
    @Published var destinationAppLocation: AppLocation?
    @Published var isAnimatePin: Bool = false
    @Published var showSearchModal: Bool = false
    @Published var updatedRegion: MKCoordinateRegion?
    private let searchCompleter = MKLocalSearchCompleter()
    
    @Published var currentLocationQuery: String = ""
    @Published var destinationLocationQuery: String = ""
    @Published var focusType: FocusField = .destinationLocation
    
    override init(){
        super.init()
        self.startSubscription()
        self.searchSubscriptions()
        self.searchCompleter.delegate = self
        
    }
    
    
    private func searchSubscriptions(){
        $currentLocationQuery
            .combineLatest($destinationLocationQuery)
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .map{(currentQuery, destinationQuery) -> String in
                return self.focusType == .destinationLocation ? destinationQuery : currentQuery
            }
            .sink { query in
                self.searchCompleter.queryFragment = query
            }
            .store(in: &cancellable)
    }
    func focusUserLocation(){
        LocationManager.shared.setUserLocationInMap()
    }
    
    func focusRoute(){
        LocationManager.shared.setCurrentRectInMap()
    }
    
    
    private func startSubscription(){
        $updatedRegion
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { region in
                if let region = region{
                    self.convertCoordinateToAddress(region)
                    self.isAnimatePin = false
                }
            }
            .store(in: &cancellable)
    }
    
    private func convertCoordinateToAddress(_ region: MKCoordinateRegion){
        let address = CLGeocoder.init()
        address.reverseGeocodeLocation(CLLocation.init(latitude: region.center.latitude, longitude:region.center.longitude)) { (places, error) in
            if error == nil{
                if let place = places?.first{
                    self.currentAppLocation = AppLocation(title: place.name ?? "None", coordinate: region.center)
                }
            }
        }
    }
    
    func selectCurrentLocation(location: MKLocalSearchCompletion) {
        self.locationSearch(forLocalSearchCompletion: location) { response, error in
            guard let item = response?.mapItems.first else { return }
            let coordinate = item.placemark.coordinate
            let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            LocationManager.shared.updateRegion(region)
        }
    }
    
    func selectDestinationLocation(location: MKLocalSearchCompletion){
        self.locationSearch(forLocalSearchCompletion: location) { response, error in
            guard let item = response?.mapItems.first else { return }
            let coordinate = item.placemark.coordinate
            self.destinationAppLocation = AppLocation(title: item.placemark.title ?? "None" , coordinate: coordinate)
//            self.mapState = .locationSelected
//            self.showSearchModal = false
        }
    }
    
   private func locationSearch(forLocalSearchCompletion localSearch: MKLocalSearchCompletion,
                        completion: @escaping MKLocalSearch.CompletionHandler) {
        
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = localSearch.title.appending(localSearch.subtitle)
        let search = MKLocalSearch(request: searchRequest)
        
        search.start(completionHandler: completion)
        
    }
}



extension SearchViewModel: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.searchResults = completer.results
//        self.status = completer.results.isEmpty ? .noResults : .result
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
//        self.status = .error(error.localizedDescription)
    }
}

enum FocusField: Int{
    case currentLocation
    case destinationLocation
}


