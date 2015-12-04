//
//  ExtensionDelegate.swift
//  HeartRate WatchKit Extension
//
//  Created by Arsen Gasparyan on 04/12/15.
//  Copyright © 2015 Arsen Gasparyan. All rights reserved.
//

import WatchKit
import WatchConnectivity

class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate {

    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
    }

    func applicationDidBecomeActive() {
        let session = WCSession.defaultSession()
        session.delegate = self
        session.activateSession()
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }

}
