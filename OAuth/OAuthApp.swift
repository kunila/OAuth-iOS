//
//  OAuthApp.swift
//  OAuth
//
//  Created by Akshaya Kunila on 12/5/23.
//

import SwiftUI

@main
struct OAuthApp: App {
    
    @ObservedObject var router = ApplicationCoordinator()

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.navigationPath) {
                LoginView(viewModel: LoginViewModel())
            }
            .environmentObject(router)
        }
    }
}
