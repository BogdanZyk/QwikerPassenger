//
//  SideMenuView.swift
//  Qwiker
//
//  Created by Богдан Зыков on 27.10.2022.
//

import SwiftUI

import SwiftUI

struct SideMenuView: View {
    
    @Binding var isShowing: Bool
//    var user: User
    @State private var showDriverRegistrationView = false
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var viewModel: HomeViewModel
    @State private var navigationTipe: SideMenuOptionViewType?
    init(isShowing: Binding<Bool>) {
        self._isShowing = isShowing
    }
    var body: some View {
        VStack(spacing: 0) {
            headerView
            menuOptionsButtons
            navigationLinks
            Spacer()
           
        }
        .padding()
        .background(Color.primaryBg)
        .navigationBarHidden(true)
    }
}

struct SideMenuView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SideMenuView(isShowing: .constant(true))
                .environmentObject(dev.homeViewModel)
                .environmentObject(AuthenticationViewModel())
        }
    }
}


// MARK: Header section
extension SideMenuView{
    private var headerView: some View{
        VStack(alignment: .leading, spacing: 20) {
            if let user = viewModel.user{
                HStack(alignment: .top){
                    UserAvatarViewComponent(pathImage: user.profileImageUrl)
                    VStack(alignment: .leading, spacing: 6) {
                        Text(user.fullname)
                            .font(.system(size: 18, weight: .semibold))
                        Text("+\(user.phoneNumber)")
                            .font(.system(size: 16))
                    }
                }
               // userForTypeActiveSection
            }
        }
        .hLeading()
    }
    
//    private var userForTypeActiveSection: some View{
//        HStack(spacing: 12) {
//            if let user = viewModel.user{
//                VStack(alignment: .leading, spacing: 10) {
//                    Text(user.accountType == .passenger ? "Do more with your account" : "DRIVER")
//                        .font(.footnote)
//                        .fontWeight(.semibold)
//                        .opacity(0.87)
//                        .padding(.bottom)
//                    Divider()
//                }
//                .padding(.top, 24)
//            }
//        }
//    }
    
    private var passengerMakeMoneyBtn: some View{
        Button {
            showDriverRegistrationView.toggle()
        } label: {
            HStack {
                Image(systemName: "dollarsign.square")
                    .font(.title2)
                    .imageScale(.medium)
                
                Text("Make Money Driving" )
                    .font(.system(size: 16, weight: .semibold))
                    .padding(6)
            }
            .foregroundColor(Color.black)
        }
    }
    

}


// MARK: List side menu section
extension SideMenuView{
    private var menuOptionsButtons: some View{
        VStack(alignment: .leading){
            ForEach(SideMenuOptionViewType.allCases, id: \.self) { option in
                Button {
                    navigationTipe = option
                } label: {
                    SideMenuOptionView(optionType: option)
                }
            }
            Button {
                authViewModel.signOut()
            } label: {
                Text("Log out")
                    .font(.title3.bold())
            }
        }
        
    }
    private var navigationLinks: some View{
        NavigationLink(tag: navigationTipe ?? .support, selection: $navigationTipe) {
            switch navigationTipe{
            case .wallet:
                Text("Wallet")
            case .trips:
                Text("MyTripsView")
            case .settings:
                Text("Settings")
            case .support:
                Text("Support")
            default:
                EmptyView()
            }
        }label: {}
            .labelsHidden()
    }
}
