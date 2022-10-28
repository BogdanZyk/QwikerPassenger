//
//  CarDetailView.swift
//  Qwiker
//
//  Created by Богдан Зыков on 28.10.2022.
//

import SwiftUI

struct CarDetailView: View {
    let animation: Namespace.ID
    @Binding var showDetailsView: Bool
    let type: RideType
    let offset: CGFloat
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
                .onTapGesture {
                    showDetailsView.toggle()
                }
            VStack(alignment: .leading, spacing: 10){
                Text(type.title)
                    .fixedSize(horizontal: true, vertical: false)
                    .font(.medelRegular(size: 40))
                    .matchedGeometryEffect(id: type.rawValue, in: animation)
                Image(type.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                    .frame(height: 200)
                    .clipped()
                    .matchedGeometryEffect(id: type.title, in: animation)
                CustomDivider().padding(.horizontal, -16)
                
                Label {
                    Text(type.aboutText)
                } icon: {
                    Image(systemName: "car.circle")
                }
                .font(.title3.weight(.medium))
                
                Spacer()
                PrimaryButtonView(title: "Close", font: .poppinsRegular(size: 18), bgColor: .gray, fontColor: .primaryBlue, isBackground: false, border: true){
                    withAnimation {
                        showDetailsView.toggle()
                    }
                }
                .padding(.bottom, 30)
            }
            .foregroundColor(.black)
            .padding()
            .onChange(of: offset) { changeOffset in
                if changeOffset == 0{
                    showDetailsView = false
                }
            }
        }
    }
}

struct CarDetailView_Previews: PreviewProvider {
    @Namespace static var animation
    static var previews: some View {
        CarDetailView(animation: animation, showDetailsView: .constant(true), type: .economy, offset: 0)
    }
}
