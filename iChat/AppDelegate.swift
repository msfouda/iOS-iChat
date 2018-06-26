//
//  AppDelegate.swift
//  iChat
//
//  Created by Mohamed Sobhi Fouda on 6/26/18.
//  Copyright © 2016 CareerFoundry. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
         FirebaseApp.configure()
        
        return true
    }

}

