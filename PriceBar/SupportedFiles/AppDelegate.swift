//
//  AppDelegate.swift
//  Price Bar
//
//  Created by Leonid Nifantyev on 6/4/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import Fabric
import Crashlytics
import GooglePlaces

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func appStart() {
        FirebaseApp.configure()
        Fabric.with([Crashlytics.self])
        GMSPlacesClient.provideAPIKey("AIzaSyANoPgVD9zYXXOYrtjFPSfIltAdRNgtYs4")
    }

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.appStart()

        self.window = UIWindow(frame: UIScreen.main.bounds)
        let module = LoginAssembler().assemble()
        self.window?.rootViewController = module
        self.window?.makeKeyAndVisible()

        return true
    }
}
