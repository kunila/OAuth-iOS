//
//  LoginView.swift
//  OAuth
//
//  Created by Akshaya Kunila on 12/5/23.
//

import SwiftUI

struct LoginView: View {
    
    @EnvironmentObject var router: ApplicationCoordinator
    @ObservedObject var viewModel: LoginViewModel
    
    var body: some View {
            VStack(spacing: 30){
                Text("Login View!")
                Button("Login") {
                    viewModel.signInpressed()
                }
            }
        .navigationDestination(isPresented: $viewModel.isAuthorized) {
            pushToView(route: .HomeTab)
        }
    }
    
}

func pushToView(route: Route)-> some View{
    let view = HomeTabView(viewModel: HomeTabViewModel())
    return view
}

#Preview {
    LoginView(viewModel: LoginViewModel())
}
