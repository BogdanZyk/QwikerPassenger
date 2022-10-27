//
//  AuthenticationViewModel.swift
//  Qwiker
//
//  Created by Богдан Зыков on 27.10.2022.
//

import FirebaseAuth
import Foundation
import GeoFireUtils
import FirebaseFirestore

final class AuthenticationViewModel: ObservableObject{
    
    
    @Published var userSession: FirebaseAuth.User?
    @Published var user: User?
    @Published var userName: String = ""
    @Published var phoneNumber: String = ""
    @Published var otpText: String = ""
    @Published var otpFields: [String] = Array(repeating: "", count: 6)
    @Published var validTextPhone: String = ""
    @Published var validTextName: String = ""
    @Published var error: Error?
    
    @Published var verificationCode: String = ""
    
    @Published var isShowLoader: Bool = false
    
    @Published var isShowVerifView: Bool = false
    
    
    init(){
        userSession = Auth.auth().currentUser
        setUser()
    }
    
    
    func actionForViewType(for state: LoginViewState){
        if checkIsValidInput(for: state){
            sendOTP()
        }
    }
    
   // MARK: - Sing in with OTR
    
    func singInWithOTR() {
        isShowLoader = true
        let code = otpFields.joined(separator: "")
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationCode, verificationCode: code)
        Auth.auth().signIn(with: credential) {[weak self] result, error in
            guard let self = self else {return}
            if let error = error {
                self.isShowLoader = false
                self.error = error
                return
            }

            self.userSession = result?.user
            self.fetchUser{ user in
                self.isShowLoader = false
                if let user = user{
                    self.user = user
                }else{
                    guard let uid = result?.user.uid, let userModel = UserService.createUserModel(withName: self.userName, phone: self.phoneNumber.formattingPhone()) else { return }
                    UserService.uploadUserData(withUid: uid, user: userModel) { error in
                        if let error = error{
                            self.error = error
                            return
                        }
                        self.setUser()
                    }
                }
            }
        }
    }



    // MARK: - Send OTP for user phone number

    func sendOTP() {
        Auth.auth().settings?.isAppVerificationDisabledForTesting = true
        if isShowLoader {return}

        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber.formattingPhone(), uiDelegate: nil) {[weak self] result, error in
            guard let self = self else {return}
            self.isShowLoader = false
            if let error = error{
                self.error = error
                return
            }
            if let verificationCode = result{
                DispatchQueue.main.async {
                    self.verificationCode = verificationCode
                    self.isShowVerifView = true
                }
            }
        }
    }


    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.user = nil
        } catch let error {
            self.error = error
        }
    }

    func fetchUser(completion: @escaping (User?) -> Void) {
        guard let uid = userSession?.uid else { return }
        UserService.fetchUser(withUid: uid) { user, error in
            if let error = error{
                print("DEBUG: \(error.localizedDescription)")
                return
            }
            completion(user)
        }
    }

    private func setUser(){
        fetchUser {[weak self] user in
            guard let self = self else {return}
            self.user = user
        }
    }

    func requestCode(){
        sendOTP()
    }
    
    
    
    func checkIsValidInput(for state: LoginViewState) -> Bool{
        
        let isValidPhone = phoneNumber.isValidPhone()
        validTextPhone = isValidPhone ? "" : "Incorrect telephone number"
        validTextName = userName.isEmpty ? "No empty user name" : ""
        return state == .login ? isValidPhone : (!userName.isEmpty && isValidPhone)
    }
    
}
