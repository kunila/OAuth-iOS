//
//  AppCoordinator.swift
//  OAuth
//
//  Created by Akshaya Kunila on 12/5/23.
//

import Foundation
import SwiftUI

public enum Route: Hashable, Codable {
    case HomeTab
    case DoorList
    case LookUpAdd
}

protocol Coordinator {
    func pushView(route: Route)
    func popToRootView()
    func popToSpecificView(k: Int)
}

open class ApplicationCoordinator: ObservableObject, Coordinator {
    
    @Published var navigationPath = NavigationPath() {
        willSet(newPath) {
            if newPath.count < navigationPath.count - 1 {
                let animation = CATransition()
                animation.isRemovedOnCompletion = true
                animation.type = .moveIn
                animation.duration = 0.4
                animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
                let scenes = UIApplication.shared.connectedScenes
                let windowScene = scenes.first as? UIWindowScene
                let window = windowScene?.windows.first
                window?.layer.add(animation, forKey: nil)
            }
        }
    }

    
    func pushView(route: Route){
        navigationPath.append(route)
    }
    
    func popToRootView() {
        navigationPath = .init()
    }
    
    func popToSpecificView(k: Int) {
        navigationPath.removeLast(k)
    }
    
}
