//
//  ViewController.swift
//  HeartRate
//
//  Created by Arsen Gasparyan on 04/12/15.
//  Copyright © 2015 Arsen Gasparyan. All rights reserved.
//

import UIKit
import WatchConnectivity
import HealthKit

class ViewController: UIViewController, WCSessionDelegate {
    private let healthStore = HKHealthStore()
    private let heartRateUnit = HKUnit(fromString: "count/min")
    private var anchor = HKQueryAnchor(fromValue: Int(HKAnchoredObjectQueryNoAnchor))
    @IBOutlet weak var label: UILabel!
    private var query: HKQuery?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func session(session: WCSession, didReceiveMessage message: [String: AnyObject]) {
        dispatch_async(dispatch_get_main_queue()) {
            let value = (message["value"] as! String)
            self.label.text = value
        }
    }
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        dispatch_async(dispatch_get_main_queue()) {
            let value = (message["value"] as! String)
            self.label.text = value
            replyHandler([String : AnyObject]())
        }
    }
    
    func sessionReachabilityDidChange(session: WCSession) {
        label.text = "Reachable: \(session.reachable)"
    }
    
    @IBAction func actionNow(sender: AnyObject) {
//        let session = WCSession.defaultSession()
//        session.delegate = self
//        label.text = "\(session.reachable) - \(session.description)"
        
//        if let query = createHeartRateStreamingQuery(NSDate()) {
//            healthStore.executeQuery(query)
//        }
        
        if let query = query {
            healthStore.stopQuery(query)
        }
        
        if let _query = createHeartRateStreamingQuery() {
            query = _query
            healthStore.executeQuery(_query)
        }
        
        label.text = "\(label.text ?? "")."
    }
    
    
    func createHeartRateStreamingQuery() -> HKQuery? {
        guard let quantityType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate) else { return .None }
        print("createHeartRateStreamingQuery")
        
        let heartRateQuery = HKAnchoredObjectQuery(type: quantityType, predicate: nil, anchor: anchor, limit: Int(HKObjectQueryNoLimit)) { (query, sampleObjects, deletedObjects, newAnchor, error) in
            if let newAnchor = newAnchor { self.anchor = newAnchor }
            self.updateHeartRate(sampleObjects)
            print("HKAnchoredObjectQuery")
        }
        
        heartRateQuery.updateHandler = {(query, samples, deleteObjects, newAnchor, error) in
            if let newAnchor = newAnchor { self.anchor = newAnchor }
            self.updateHeartRate(samples)
            print("updateHandler")
        }

        return heartRateQuery
    }
    
    func updateHeartRate(samples: [HKSample]?) {
        guard let heartRateSamples = samples as? [HKQuantitySample] else {return}
        
        dispatch_async(dispatch_get_main_queue()) {
            guard let sample = heartRateSamples.first else { return }
            let value = String(UInt16(sample.quantity.doubleValueForUnit(self.heartRateUnit)))
            self.label.text = value
        }
    }
}

