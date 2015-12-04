//
//  AppDelegate.swift
//  HeartRate
//
//  Created by Arsen Gasparyan on 04/12/15.
//  Copyright © 2015 Arsen Gasparyan. All rights reserved.
//

import UIKit
import HealthKit
import WatchConnectivity

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate {
    var window: UIWindow?
    private let healthStore = HKHealthStore()


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }


    func applicationShouldRequestHealthAuthorization(application: UIApplication) {
        healthStore.handleAuthorizationForExtensionWithCompletion { success, error in }
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        let session = WCSession.defaultSession()
        session.delegate = self
        session.activateSession()
    }
}

