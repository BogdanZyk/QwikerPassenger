//
//  VerificationView.swift
//  Qwiker
//
//  Created by Богдан Зыков on 27.10.2022.
//

import SwiftUI

struct VerificationView: View {
    @State private var isHiddenTimer: Bool = false
    @State private var timeRemaining: Int = 30
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let verificationRange = 0..<6
    @EnvironmentObject var authVM: AuthenticationViewModel
    @FocusState var activeField: OTPField?
    var body: some View {
        VStack(spacing: 40){
            backButton
            title
            verifInpurSection
            Spacer()
        }
        .hCenter()
        .background(Color.primaryBg)
        .handle(error: $authVM.error)
        .onAppear{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                activeField = .field1
            }
        }
        .onChange(of: authVM.otpFields) { newValue in
            otpConditions(value: newValue)
        }
        .onReceive(timer) { _ in
            if timeRemaining > 0{
                timeRemaining -= 1
            }else if timeRemaining <= 0{
                stopTimer()
            }
        }
    }
}

struct VerificationView_Previews: PreviewProvider {
    static var previews: some View {
        VerificationView()
            .environmentObject(AuthenticationViewModel())
    }
}

extension VerificationView{
    private var title: some View{
        VStack(alignment: .center, spacing: 20) {
            Text("Enter verification code")
                .font(.poppinsMedium(size: 23))
            Text("A code has been sent to ").font(.poppinsRegular(size: 14)).foregroundColor(.gray) + Text(authVM.phoneNumber).font(.poppinsMedium(size: 16))
        }
    }
    private var OTPField: some View{
        HStack(spacing: 14){
            ForEach(verificationRange, id: \.self){index in
                VStack(spacing: 5) {
                    TextField("", text: $authVM.otpFields[index])
                        .font(.title2.weight(.semibold))
                        .keyboardType(.numberPad)
                        .textContentType(.oneTimeCode)
                        .multilineTextAlignment(.center)
                        .focused($activeField, equals: activeStateForIndex(for: index))
                    Rectangle()
                        .fill(activeField == activeStateForIndex(for: index) ? Color.primaryBlue : .gray.opacity(0.3))
                        .frame(height: 4)
                }
                .frame(width: 40)
                .padding(.trailing, index == 2 ? 30 : 0)
            }
        }
    }
    
    private var verifButton: some View{
        PrimaryButtonView(showLoader: authVM.isShowLoader, title: "Verify") {
            authVM.singInWithOTR()
        }
    }
    
    private var sendAgainSection: some View{
        HStack {
            if isHiddenTimer{
                Button {
                    authVM.requestCode()
                } label: {
                    Text("Send the code again")
                }
                
            }else{
                Text("Send more code in \(timeRemaining) seconds")
            }
        }
        .font(.footnote)
        .foregroundColor(.blue)
    }
    
    private var verifInpurSection: some View{
        VStack(alignment: .center, spacing: 30) {
            OTPField
            sendAgainSection
            verifButton
        }
        .padding(.horizontal)
    }
    
    private var backButton: some View{
        Button {
            authVM.isShowVerifView.toggle()
        } label: {
            Image(systemName: "chevron.left")
                .imageScale(.medium)
                .foregroundColor(.black)
                .padding()
                .background{
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 0)
                }
        }
        .padding()
        .hLeading()
    }
}






//MARK: - Conditions For Custom OTP Field & Limitind only one text
extension VerificationView{
    private func otpConditions(value: [String]){
        
        // Checking if OTP is pressed
        verificationRange.forEach { index in
            if value[index].count == 6{
                DispatchQueue.main.async {
                    authVM.otpText = value[index]
                    for item in authVM.otpText.enumerated(){
                        authVM.otpFields[item.offset] = String(item.element)
                    }
                }
            }
        }
        
        
        // Send request for all inputs is not empty
        if value.map({!$0.isEmpty}).allSatisfy({$0}){
            authVM.singInWithOTR()
        }
        
        
        // Moving next filed if current field type
        for index in 0..<5{
            if value[index].count == 1 && activeStateForIndex(for: index) == activeField{
                activeField = activeStateForIndex(for: index + 1)
            }
        }
        // Moving back is current is empty and previuos is not empty
        
        for index in 1...5{
            if value[index].isEmpty && !value[index - 1].isEmpty{
                activeField = activeStateForIndex(for: index - 1)
            }
        }
        
        verificationRange.forEach { index in
            if value[index].count > 1{
                authVM.otpFields[index] = String(value[index].last!)
            }
        }
    }
}

//MARK: Timer logic
extension VerificationView{
    private func startTimer(){
        isHiddenTimer = false
        timeRemaining = 30
        timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    }
    private func stopTimer(){
        isHiddenTimer = true
        timer.upstream.connect().cancel()
    }
}



//MARK: - Focus tf logic
extension VerificationView{
    private func activeStateForIndex(for index: Int) -> OTPField{
        switch index{
        case 0: return .field1
        case 1: return .field2
        case 2: return .field3
        case 3: return .field4
        case 4: return .field5
        default: return .field6
        }
    }
    
    private func checkState() -> Bool{
        for index in verificationRange{
            if authVM.otpFields[index].isEmpty {return true}
        }
        return false
    }
}



enum OTPField{
    case field1, field2, field3, field4, field5, field6
}
