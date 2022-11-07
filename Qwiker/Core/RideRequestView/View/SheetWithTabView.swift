//
//  SheetWithTabView.swift
//  Qwiker
//
//  Created by Богдан Зыков on 28.10.2022.
//

import SwiftUI

struct SheetWithTabView: View{
    let sheetHeight: CGFloat
    let proxyFrame: CGRect
    @EnvironmentObject var homeVM: HomeViewModel
    @Namespace private var animation
    @Binding var showPaymentInfoSheet: Bool
    @Binding var offset: CGFloat
    @State private var showDetailsView: Bool = false
    var body: some View{
        ZStack(alignment: .top){
            VStack(spacing: 0) {
                pageControlView
                
                if -offset > 10{
                    expandedTabViewSection
                        .matchedGeometryEffect(id: "Shape", in: animation, anchor: .leading)
                }else{
                    foldedBottomScrollSectionView
                        .matchedGeometryEffect(id: "Shape", in: animation, anchor: .leading)
                }
            }
            draggIcon
            if showDetailsView {
                CarDetailView(animation: animation, showDetailsView: $showDetailsView, type: homeVM.selectedRideType, offset: offset)
            }
        }
    }
}

struct SheetWithTabView_Previews: PreviewProvider {
    static var previews: some View {
        RideRequestExpandSheetView()
            .environmentObject(dev.homeViewModel)
    }
}

//MARK: - Expanded and Folded sections view
extension SheetWithTabView{
    
    private var foldedBottomScrollSectionView: some View{
        VStack(alignment: .leading, spacing: 15){
            locationButtonsView
            scrollDriveTypeSection
            bottomSectionView
            Spacer()
        }
        .frame(width: getRect().width)
        .background(Color.white)
        .cornerRadius(12)
    }
    
    private var expandedTabViewSection: some View{
        VStack(spacing: 0) {
            TabView(selection: $homeVM.selectedRideType) {
                ForEach(RideType.allCases, id:\.self) {type in
                    VStack(alignment: .leading, spacing: 10){
                        locationButtonsView
                        customDivider
                        infoExpandSectionView(type)
                        customDivider
                        listSectionView
                        Spacer()
                        bottomSectionView
                        
                    }
                    .frame(width: getRect().width)
                    .background(Color.white)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .transition(.opacity)
        }
    }
}

//MARK: - Components for Folded view
extension SheetWithTabView{
    
    private var scrollDriveTypeSection: some View{
        ScrollViewReader { reader in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack{
                    ForEach(RideType.allCases, id: \.self) { type in
                        HStack{
                            VStack(alignment: .leading, spacing: 4){
                                Text(homeVM.ridePriceForType(type).toCurrency())
                                    .font(.poppinsRegular(size: 12))
                                Text("\(type.title)")
                                    .font(.poppinsMedium(size: 14))
                            }
                            .font(.subheadline)
                            .foregroundColor(Color.black)
                            .padding(.horizontal, 8)
                            Image(type.imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 60)
                                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                        }
                        .frame(width: getRect().width / 2.35, height: 70)
                        .scaleEffect(type == homeVM.selectedRideType ? 1.1 : 1, anchor: .center)
                        .background(type == homeVM.selectedRideType ? Color.primaryBlue : Color.black.opacity(0.2), in: RoundedRectangle(cornerRadius: 3).stroke(lineWidth: type == homeVM.selectedRideType ? 2 : 1))
                        .padding(.vertical, 2)
                        .id(type)
                        .onTapGesture {
                            DispatchQueue.main.async {
                                withAnimation(.easeOut) {
                                    homeVM.selectedRideType = type
                                    reader.scrollTo(type, anchor: .center)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
}

//MARK: - Components for Expanded view
extension SheetWithTabView{
    
    private func infoExpandSectionView(_ type: RideType) -> some View{
        VStack(alignment: .leading, spacing: 0){
            HStack{
                Text(type.title)
                    .font(.medelRegular(size: 33))
                    .lineLimit(1)
                    .matchedGeometryEffect(id: type.rawValue, in: animation)
                Spacer()
                Text(homeVM.ridePriceForType(type).toCurrency())
                    .font(.poppinsMedium(size: 20))
            }
            .padding(.horizontal)
            HStack{
                Image(type.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                    .frame(height: 150)
                    .padding()
                    .hLeading()
                    .scaleEffect(Double(abs(offset) * 0.01) / 5)
                    .opacity(Double(abs(offset) * 0.01) / 5)
                    .clipped()
                    .matchedGeometryEffect(id: type.title, in: animation)
                Spacer()
                Image(systemName: "chevron.right.circle.fill")
                    .imageScale(.large)
                    .foregroundColor(Color.black.opacity(0.5))
                    .padding()
            }
            .onTapGesture {
                withAnimation {
                    showDetailsView.toggle()
                }
            }
        }
    }
}

//MARK: - Bottom view component section
extension SheetWithTabView{
    private var bottomSectionView: some View{
        let fullHeigh = -proxyFrame.height + sheetHeight
        return HStack(spacing: 20){
            Button {
                withAnimation {
                    showPaymentInfoSheet.toggle()
                }
            } label: {
                Image("cash-icon")
                    .resizable()
                    .frame(width: 35, height: 35)
            }
            PrimaryButtonView(showLoader: false, title: "Request \(homeVM.selectedRideType.title)") {
                homeVM.requestRide()
            }
            .withoutAnimation()
            Button {
                
                withAnimation(.easeInOut){
                    offset = offset == fullHeigh ? 0 : fullHeigh
                }
            } label: {
                Image(systemName: offset == fullHeigh ? "chevron.down" : "line.3.horizontal")
                    .font(.title.weight(.light))
                    .foregroundColor(.black)
                    .frame(width: 35, height: 35)
            }
            
        }
        
        .frame(height: 60)
        .padding(.horizontal)
        .background{
            if offset == fullHeigh{
                Color.primaryBg
            }else{
                Color.primaryBg.shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: -5)
            }
        }
    }
}

//MARK: - Other components
extension SheetWithTabView{
    private var draggIcon: some View{
        JumpingDraggIcon(isExpand:  (-proxyFrame.height + sheetHeight) == offset)
            .offset(y: -(offset / 25))
    }
    
    private var pageControlView: some View{
        
        return Group {
            HStack{
                ForEach(RideType.allCases, id: \.self){type in
                    Circle()
                        .fill(homeVM.selectedRideType == type ? Color.gray.opacity(0.3) : Color.black.opacity(0.5))
                        .frame(width: 8, height: 8)
                }
            }
            .opacity((Double(abs(offset) * 0.01) / 5))
            .offset(y: -5)
        }
    }
    
    private var locationButtonsView: some View{
        
        VStack(alignment: .leading, spacing: 10) {
            locationLabel()
            locationLabel(isDestination: true)
        }
        .font(.headline)
        .padding(.horizontal)
        .padding(.top)
    }
    
    
    private func listCellView(title: String) -> some View{
        HStack{
            Text(title)
                .font(.subheadline.weight(.medium))
            
            Spacer()
            Image(systemName: "chevron.right")
        }
        .foregroundColor(.black)
    }
    
    private var listSectionView: some View{
        VStack(spacing: 20) {
            Button {
                
            } label: {
                listCellView(title: "Comments to the driver")
            }
            Divider()
            Button {
                
            } label: {
                listCellView(title: "Order to another person")
            }
        }
        .padding(.horizontal)
    }
    
    private var customDivider: some View{
        CustomDivider()
    }
    
    private func locationLabel(isDestination: Bool = false) -> some View{
        HStack(alignment: .lastTextBaseline) {
            Circle()
                .stroke(lineWidth: 3)
                .fill(isDestination ? Color.primaryBlue : Color.gray)
                .frame(width: 8, height: 8)
            VStack(alignment: .leading, spacing: 15){
                HStack(spacing: 10) {
                    Text(isDestination ? homeVM.selectedLocation?.title ?? "Destination" : homeVM.userLocation?.title ?? "Current location")
                        .lineLimit(1)
                        .font(.subheadline.weight(.medium))
                     .foregroundColor(isDestination ? Color.black : .gray)
                    if isDestination{
                        if let time = homeVM.dropOffTime{
                            Text(time)
                                .font(.callout)
                                .foregroundColor(.gray)
                        }
                    }
                }
                Divider()
            }
        }
    }
}





struct CustomDivider: View{
    var verticalPadding: CGFloat = -10
    var lineHeight: CGFloat = 6
    var body: some View{
        Rectangle()
            .fill(Color.gray.opacity(0.1))
            .frame(height: lineHeight)
            .padding(.vertical, verticalPadding)
    }
}
