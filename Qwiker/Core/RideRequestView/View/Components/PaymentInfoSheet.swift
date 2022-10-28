//
//  PaymentInfoSheet.swift
//  Qwiker
//
//  Created by Богдан Зыков on 28.10.2022.
//


import SwiftUI

struct PaymentInfoSheet: View {
    let card: Card? = Card()
    @State private var showInputCardSheet: Bool = false
    @State private var currentPaymentMethod: PaymentMetodType = .cash
    @Binding var showPaymentInfoSheet: Bool
    var body: some View {
        ZStack{
            Color.primaryBg.ignoresSafeArea()
            VStack(spacing: 0){
                headerView
                cardSection
                divider
                cashButton
                applePayButton
                Spacer()
                submitButton
            }
        }
        .frame(height: getRect().height / 2.5)
        .sheet(isPresented: $showInputCardSheet) {
            Text("InputCardSheet")
        }
    }
}

struct PaymentInfoSheet_Previews: PreviewProvider {
    static var previews: some View {
        PaymentInfoSheet(showPaymentInfoSheet: .constant(true))
    }
}

extension PaymentInfoSheet{
    private var headerView: some View{
        Text("Payment methods")
            .font(.poppinsMedium(size: 20))
            .foregroundColor(.white)
            .hCenter()
            .frame(height: 60)
            .background(Color.primaryBlue)
    }
    
    private var cardSection: some View{
        Group{
            if let card = card{
                    Button {
                        currentPaymentMethod = .card
                    } label: {
                        HStack{
                            Label(title: {
                                Text(card.getLastFourCharactersForCardNumber)
                            }, icon: {
                                Text("VISA")
                            })
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.blue)
                            .cornerRadius(5)
                            Spacer()
                            if currentPaymentMethod == .card{
                                Image(systemName:"checkmark")
                                    .font(.subheadline.bold())
                                    .foregroundColor(.black)
                            }
                        }
                    }
                
            }else{
                Button {
                    showInputCardSheet.toggle()
                } label: {
                    HStack{
                        Text("Add card")
                            .font(.headline)
                        Spacer()
                        Image(systemName:"chevron.forward")
                            .imageScale(.small)
                    }
                    .foregroundColor(.black)
                }
            }
        }
        .padding()
    }
    
    private var cashButton: some View{
        Button {
            currentPaymentMethod = .cash
        } label: {
            HStack{
                Text("Cash")
                    .font(.headline)
                    
                Spacer()
                if currentPaymentMethod == .cash{
                    Image(systemName:"checkmark")
                        .font(.subheadline.bold())
                }
            }
            .foregroundColor(.black)
            .padding()
        }
    }
    
    
    private var applePayButton: some View{
        Button {
            currentPaymentMethod = .applePay
        } label: {
            HStack{
                Text("Apple Pay")
                    .font(.headline)
                Spacer()
                if currentPaymentMethod == .applePay{
                    Image(systemName:"checkmark")
                        .font(.subheadline.bold())
                        .foregroundColor(.black)
                }
            }
            .foregroundColor(.black)
            .padding()
        }
    }
    
    private var submitButton: some View{
        PrimaryButtonView(title: "Continue", font: .poppinsRegular(size: 18), bgColor: .gray, fontColor: .primaryBlue, isBackground: false, border: true){
            withAnimation {
                showPaymentInfoSheet.toggle()
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
    
    private var divider: some View{
        CustomDivider(verticalPadding: 0, lineHeight: 8)
    }
}


enum PaymentMetodType: Int{
    case card, cash, applePay
    
    func getLastFourCharactersForCardNumber(_ number: String) -> String?{
        if self == .card{
           
        }
        return nil
    }
}

struct Card{
    var number: String = "12344433"
    var date: String = ""
    var cvv: String = ""
    
    var getLastFourCharactersForCardNumber: String{
        number.count > 4 ? String(number.suffix(4)) : "none"
    }
}
