//
//  UserProfileView.swift
//  Milestone 4
//
//  Created by Abhishek-Sreejith on 17/10/23.
//

import SwiftUI
struct UserProfileView: View {
    @EnvironmentObject private var user: FirestoreManager
    // @ObservedObject var viewModel = FirebaseManager()
    @Environment(\.presentationMode) var presentationMode
    // @Environment(\.dismiss) var dismis
    var body: some View {
        VStack {
            VStack {
            Button {
                self.presentationMode.wrappedValue.dismiss()
            } label: {
                Text("Cancel")
            }.padding(.leading, 5)
            }.frame(maxWidth: .infinity, maxHeight: 54, alignment: .leading)
            VStack(spacing: 20) {
                Image(uiImage: (self.user.imageView ?? UIImage(named: "people_fill"))!)
                    .resizable()
                    .frame(width: 125, height: 125, alignment: .center)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(.white, lineWidth: 2)).shadow(radius: 2)
                    .foregroundColor(Color(UIColor.darkGray))
                Text(user.name)
                    .bold()
                    .font(.custom("TiltNeon-Regular", size: 25))
                Text(user.email)
                    .bold()
                    .font(Font.custom("TiltNeon-Regular", size: 15))
                Button {
                    print("Button Pressed")
                } label: {
                    HStack {
                        Text("Start Messaging")
                        Image("send")
                            .resizable()
                            .frame(width: 20, height: 20, alignment: .center)
                            .clipShape(Circle())
                    }
                    .foregroundColor(Color("ButtonLabelColor"))
                }
                .padding()
                .background(Color(UIColor.opaqueSeparator))
                .clipShape(RoundedRectangle(cornerRadius: 13))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.top, 20)
        }.background(Color("MainScreenColor"))
    }
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView()
            .environmentObject(FirestoreManager())
    }
}
