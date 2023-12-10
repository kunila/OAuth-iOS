//
//  AppDelegate.swift
//  OAuth
//
//  Created by Akshaya Kunila on 12/6/23.
//

import Foundation
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        Task{
            let center = UNUserNotificationCenter.current()
            let authorizationStatus = await center.notificationSettings().authorizationStatus
            
            if(authorizationStatus == .authorized)
            {
                await MainActor.run {
                    application.registerForRemoteNotifications()
                }
            }
        }
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let token = deviceToken.reduce("") {$0 + String(format: "%02x", $1)}
        print("device token: \(token)")
        // send the token to your server
        forwardTokenToServer(token: deviceToken)

    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error)
    }
    
    func forwardTokenToServer(token: Data) {
        let tokenComponents = token.map { data in String(format: "%02.2hhx", data) }
        let deviceTokenString = tokenComponents.joined()
        let queryItems = [URLQueryItem(name: "deviceToken", value: deviceTokenString)]
        var urlComps = URLComponents(string: "www.example.com/register")!
        urlComps.queryItems = queryItems
        guard let url = urlComps.url else {
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            // Handle data
        }

        task.resume()
    }
}
