//
//  LocationSearchView.swift
//  Qwiker
//
//  Created by Bogdan Zykov on 27.10.2022.
//

import SwiftUI

struct LocationSearchView: View {
    @FocusState var focused: FocusField?
    @EnvironmentObject var searchVM: SearchViewModel
    @Binding var mapState: MapViewState
    @State private var startLocationText = ""
    @State private var isAnimate: Bool = false
    var body: some View {
        VStack(spacing: 0){
            headerSectionView
            searchResultSectionView
        }
        
        .onChange(of: focused ?? .destinationLocation) { newValue in
            searchVM.focusType = newValue
        }
        .onAppear{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                searchVM.focusType = .destinationLocation
                focused = .destinationLocation
            }
        }
        .onDisappear{
            searchVM.focusType = nil
        }
        .padding(.horizontal)
        .padding(.top, getRect().height / 14)
        .background(Color.primaryBg)
    }
}

struct LocationSearchView_Previews: PreviewProvider {
    static var previews: some View {
        LocationSearchView(mapState: .constant(.searchingForLocation))
            .environmentObject(SearchViewModel())
    }
}



// MARK: Header section
extension LocationSearchView{
    private var headerSectionView: some View{
        VStack(alignment: .leading, spacing: 15){
            currentLocationTf
            Divider().padding(.leading, 20)
            destinationTf
        }
        .padding()
        .background{
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 10)
        }
    }
    
    private var currentLocationTf: some View{
        HStack(spacing: 15){
            Circle().stroke(lineWidth: 3)
                .fill(Color.primaryBlue)
                .frame(width: 10, height: 10)
                TextField("Current location", text: $searchVM.currentLocationQuery)
                .focused($focused, equals: .currentLocation)
                .font(.poppinsRegular(size: 16))
        }
    }
    private var destinationTf: some View{
        HStack(spacing: 15){
            Image(systemName: "magnifyingglass")
                .imageScale(.small)
            TextField("Destination", text: $searchVM.destinationLocationQuery)
                .focused($focused, equals: .destinationLocation)
            .font(.poppinsRegular(size: 16))
        }
    }
}


extension LocationSearchView{
    private var searchResultSectionView: some View{
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 10){
                ForEach(searchVM.searchResults, id: \.self) {
                    result in
                    Button {
                        UIApplication.shared.endEditing()
                        searchVM.setLocationForFocusField(for: focused ?? .currentLocation, location: result) {
                            withAnimation(.easeInOut){
                                mapState = .locationSelected
                            }
                        }
                    } label: {
                        LocationResultViewCell(title: result.title, subtitle: result.subtitle)
                    }
                }
            }
            .padding()
            .padding(.leading)
        }
    }
}
