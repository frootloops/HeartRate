//
//  InterfaceController.swift
//  HeartRate WatchKit Extension
//
//  Created by Arsen Gasparyan on 04/12/15.
//  Copyright © 2015 Arsen Gasparyan. All rights reserved.
//

import WatchKit
import Foundation
import HealthKit
import WatchConnectivity


class InterfaceController: WKInterfaceController, HKWorkoutSessionDelegate {
    @IBOutlet private weak var label: WKInterfaceLabel!
    @IBOutlet private weak var deviceLabel : WKInterfaceLabel!
    @IBOutlet private weak var startStopButton : WKInterfaceButton!
    
    private let healthStore = HKHealthStore()
    private var workoutActive = false
    private var workoutSession: HKWorkoutSession?
    private let heartRateUnit = HKUnit(fromString: "count/min")
    private var anchor = HKQueryAnchor(fromValue: Int(HKAnchoredObjectQueryNoAnchor))

    override func willActivate() {
        super.willActivate()
        
        guard HKHealthStore.isHealthDataAvailable() else { return }
        guard let quantityType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate) else { return }
        let dataTypes = Set(arrayLiteral: quantityType)
        
        healthStore.requestAuthorizationToShareTypes(nil, readTypes: dataTypes) { (success, error) in }
    }
    
    @IBAction func buttonTapped() {
        if (workoutActive) {
            workoutActive = false
            startStopButton.setTitle("Start")
            
            if let workout = workoutSession {
                healthStore.endWorkoutSession(workout)
            }
        } else {
            workoutActive = true
            startStopButton.setTitle("Stop")
            startWorkout()
        }
    }
    
    
    func workoutSession(workoutSession: HKWorkoutSession, didChangeToState toState: HKWorkoutSessionState, fromState: HKWorkoutSessionState, date: NSDate) {
        switch toState {
        case .Running: workoutDidStart(date)
        case .Ended:   workoutDidEnd(date)
        default: break
        }
    }
    
    func workoutSession(workoutSession: HKWorkoutSession, didFailWithError error: NSError) {}
    
    func workoutDidStart(date: NSDate) {
        if let query = createHeartRateStreamingQuery(date) {
            healthStore.executeQuery(query)
        }
    }
    
    func workoutDidEnd(date: NSDate) {
        if let query = createHeartRateStreamingQuery(date) {
            healthStore.stopQuery(query)
            label.setText("---")
        }
    }
    
    func startWorkout() {
        workoutSession = HKWorkoutSession(activityType: .CrossTraining, locationType: .Indoor)
        workoutSession?.delegate = self
        healthStore.startWorkoutSession(workoutSession!)
    }
    
    func createHeartRateStreamingQuery(workoutStartDate: NSDate) -> HKQuery? {
        guard let quantityType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate) else { return .None }
        
        let heartRateQuery = HKAnchoredObjectQuery(type: quantityType, predicate: nil, anchor: anchor, limit: Int(HKObjectQueryNoLimit)) { (query, sampleObjects, deletedObjects, newAnchor, error)  in
            guard let newAnchor = newAnchor else { return }
            self.anchor = newAnchor
            self.updateHeartRate(sampleObjects)
        }
        
        heartRateQuery.updateHandler = {(query, samples, deleteObjects, newAnchor, error) in
            self.anchor = newAnchor!
            self.updateHeartRate(samples)
        }
        return heartRateQuery
    }
    
    func updateHeartRate(samples: [HKSample]?) {
        guard let heartRateSamples = samples as? [HKQuantitySample] else {return}
        
        dispatch_async(dispatch_get_main_queue()) {
            guard let sample = heartRateSamples.first else{ return }
            let value = String(UInt16(sample.quantity.doubleValueForUnit(self.heartRateUnit)))
            self.label.setText(value)
//            let session = WCSession.defaultSession()
//            session.sendMessage(["value": value], replyHandler: nil, errorHandler: { error in
//                self.deviceLabel.setText(error.localizedDescription)
//            })
        }
    }

}
