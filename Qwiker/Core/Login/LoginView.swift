//
//  LoginView.swift
//  Qwiker
//
//  Created by Богдан Зыков on 27.10.2022.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authVM: AuthenticationViewModel
    @AppStorage("isShowOnboarding") var isShowOnboarding: Bool = true
    @State private var viewState: LoginViewState = .login
    var body: some View {
        NavigationView {
            ZStack{
              
                switch viewState {
                case .login:
                    signInView
                        .transition(.move(edge: .leading))
                case .signup:
                    createAccoutView
                        .transition(.move(edge: .leading))
                }
                
                NavigationLink(isActive: $authVM.isShowVerifView) {
                    VerificationView()
                        .environmentObject(authVM)
                        .navigationBarHidden(true)
                } label: {}
                    .labelsHidden()

            }
            .handle(error: $authVM.error)
            .navigationBarHidden(true)
        }
        .fullScreenCover(isPresented: $isShowOnboarding) {
            OnboardingView()
                .preferredColorScheme(.light)
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthenticationViewModel())
    }
}

extension LoginView{
    
    
    private var createAccoutView: some View{
        VStack(spacing: 20){
            title
            inputSection
            Spacer()
            alredyAccountSection
        }
        .allFrame()
        .background(Color.primaryBg)
    }
    
    private var signInView: some View{
        VStack(spacing: 20){
            title
            inputSection
            Spacer()
            alredyAccountSection
        }
        .allFrame()
        .background(Color.primaryBg)
    }
   
    private var inputSection: some View{
        VStack(spacing: 20) {
            if viewState == .login{
                subtitle
            }else{
                userNameTf
            }
            phoneTf
            validSection
            submitButton
        }
        .padding()
    }
    
    private var validSection: some View{
        Group{
            if viewState == .login{
                validText(authVM.validTextPhone)
            }else{
                validText(authVM.validTextPhone)
                validText(authVM.validTextName)
            }
        }.padding(.vertical, -10)
    }
    
    private var title: some View{
        Text(viewState.title)
            .font(.medelRegular(size: 30))
            .padding(.top, 50)
    }
    
    private var phoneTf: some View{
        PrimaryTextFieldView(label: "Phone Number", text:  Binding(
            get: { authVM.phoneNumber },
            set: { authVM.phoneNumber = $0.filter { "0123456789".contains($0)}}))
        .keyboardType(.numberPad)
        .textContentType(.telephoneNumber)
        .onChange(of: authVM.phoneNumber) { _ in
            authVM.validTextPhone = ""
        }
    }
    
    private var userNameTf: some View{
        PrimaryTextFieldView(label: "Your name", text: $authVM.userName)
            .onChange(of: authVM.userName) { _ in
                authVM.validTextName = ""
            }
    }
    
    private var subtitle: some View{
        Text("Login with your phone number")
            .font(.poppinsRegular(size: 18))
    }
    
    private func validText(_ text: String) -> some View{
        Text(text)
            .font(.poppinsRegular(size: 16))
            .foregroundColor(.red)
    }
    
    private var alredyAccountSection: some View{
        HStack {
            Text(viewState.alredyTitle)
            Button {
                withAnimation {
                    viewState = viewState == .login ? .signup : .login
                }
            } label: {
                Text(viewState == .login ? "Sign up" : "Log in")
                    .font(.poppinsMedium(size: 18))
                    .foregroundColor(.primaryBlue)
            }
        }
    }
    private var submitButton: some View{
        PrimaryButtonView(showLoader: authVM.isShowLoader, title: viewState == .login ? "Send code" : "Sign Up") {
            authVM.actionForViewType(for: viewState)
        }
    }
}



enum LoginViewState: Int{
    case login, signup
    
    var title: String{
        switch self {
        case .login:
            return "Log in"
        case .signup:
           return "Sign Up"
        }
    }
    var alredyTitle: String{
        switch self {
        case .login:
            return "Don’t have an account?"
        case .signup:
           return "Already have an account?"
        }
    }
}
