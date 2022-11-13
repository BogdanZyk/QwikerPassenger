//
//  SideMenuView.swift
//  Qwiker
//
//  Created by Богдан Зыков on 27.10.2022.
//


import SwiftUI

struct SideMenuView: View {
    
    @Binding var isShowing: Bool
    @State private var showDriverRegistrationView = false
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var viewModel: HomeViewModel
    @State private var navigationTipe: SideMenuOptionViewType?
    init(isShowing: Binding<Bool>) {
        self._isShowing = isShowing
    }
    var body: some View {
        VStack(spacing: 10) {
            headerView
            CustomDivider(verticalPadding: 0, lineHeight: 10).padding(.horizontal, -16)
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
                    VStack(alignment: .leading, spacing: 6) {
                        Text(user.fullname)
                            .font(.system(size: 18, weight: .semibold))
                        Text(user.phoneNumber)
                            .font(.system(size: 16))
                    }
                }
            }
        }
        .hLeading()
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
            PrimaryButtonView(title: "Log out", bgColor: .secondaryGrey.opacity(0.3), fontColor: .secondaryGrey) {
                authViewModel.signOut()
            }
            .padding(.vertical, 20)
        }
        
    }
    private var navigationLinks: some View{
        NavigationLink(tag: navigationTipe ?? .support, selection: $navigationTipe) {
            switch navigationTipe{
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
