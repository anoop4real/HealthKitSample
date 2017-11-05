//
//  HealthKitManager.swift
//  HealthKitSample
//
//  Created by anoopm on 04/11/17.
//  Copyright © 2017 anoopm. All rights reserved.
//

import Foundation
import HealthKit
import UIKit

enum HealthKitError: Error{
    
    case notSupportedInDevice
    case dataTypeNotAvailable
    
}
enum HealthKitErrorCode: Int{
    case noSourceAvailable = 999
}
enum Result<T, E> {
    case success(T)
    case error(E)
}

class HealthKitManager{

    private var isHealthDataSourceAvailable = true
    private var isHealthKitAuthScreenShown = false
    private var observerQuery:HKObserverQuery!
    private static let _shared = HealthKitManager()
    
    private init(){
        
    }
    
    class func shared() -> HealthKitManager{
        
        return _shared
    }
    // Method fired to authorize healthkit access
    func authorizeHealthKit(completion: @escaping (Result<Bool,Error>) -> Void){
        
        // If healthkit is not supported in the device return
        if !isHealthKitAvailable(){
            
            completion(.error(HealthKitError.notSupportedInDevice))
        }
        
        // Check for whether all the required datatypes exists.
//        guard   let dOB = HKObjectType.characteristicType(forIdentifier: .dateOfBirth),
//            let height = HKObjectType.quantityType(forIdentifier: .height),
//            let bloodType = HKObjectType.characteristicType(forIdentifier: .bloodType),
//            let steps = HKObjectType.quantityType(forIdentifier: .stepCount),
//            let biologicalSex = HKObjectType.characteristicType(forIdentifier: .biologicalSex),
//            let bodyMassIndex = HKObjectType.quantityType(forIdentifier: .bodyMassIndex),
//            let bodyMass = HKObjectType.quantityType(forIdentifier: .bodyMass),
//            let activeEnergy = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {
//                
//                completion(.error(HealthKitError.dataTypeNotAvailable))
//                return
//        }
        // We would like to get the steps data of the user.
        guard let steps = HKObjectType.quantityType(forIdentifier: .stepCount)
            else {
                
                completion(.error(HealthKitError.dataTypeNotAvailable))
                return
        }
        
        // Now that screen shows
        HealthKitManager.shared().setAuthScreenShown(status: true)
        //let healthKitDataToWrite: Set<HKSampleType> = [steps]
        
        let healthKitDataToRead: Set<HKObjectType> = [steps]
        
        HKHealthStore().requestAuthorization(toShare: nil, read: healthKitDataToRead) {[weak self] (status, error) in
            
            if status {
                // Set an observer query for immediately getting the data updated to Health store
                self?.setUpObserverQueryFor(identifier: .stepCount)
                completion(.success(true))
            }else {
                if let err = error{
                    completion(.error(err))
                }else{
                    completion(.success(false))
                }
                
            }
        }
    }
    
    // Set an observer query for immediately getting the data updated to Health store
    func setUpObserverQueryFor(identifier: HKQuantityTypeIdentifier){

        guard let sampleType = HKObjectType.quantityType(forIdentifier: identifier)
            else {
                return
        }

        if !(observerQuery != nil) {
            observerQuery = HKObserverQuery(sampleType: sampleType, predicate: nil, updateHandler: { (query , completionHandler, error) in
                if error != nil {
                    // Perform Proper Error Handling Here...
                    print("*** An error occured while setting up the stepCount observer. \(String(describing: error?.localizedDescription)) ***")
                    //abort();
                }else{
                    completionHandler()
                }
            })

            // run it
            HKHealthStore().execute(observerQuery)
            HKHealthStore().enableBackgroundDelivery(for: sampleType, frequency: .immediate, withCompletion: { (status, error) in
                if status {
                    print("Data delivered from background")
                }
                else {
                    print("Error \(String(describing: error?.localizedDescription))")
                }
            })
        }
    }
    
    // Method to get the available HK sources
    func getPreferredSourceFor(identifier: HKQuantityTypeIdentifier, withCompletion completion: @escaping (Result<HKSource?, Error?>) -> Void) {
        guard let sampleType = HKObjectType.quantityType(forIdentifier: identifier)
            else {
                return
        }
        let deviceName: String = UIDevice.current.name
        let sourceQuery = HKSourceQuery(sampleType: sampleType, samplePredicate: nil) { (query, sources, error) in
            
            if error != nil{
                
                completion(.error(error))
            }
            
            guard let sourcesData = sources else{
                completion(.success(nil))
                return
            }
            
            if !sourcesData.isEmpty{
                
                for source in sourcesData {
                    // the device itself, we want that.
                    if source.name.isEqual(deviceName) {
                        completion(.success(source))
                    }
                }
            }
            
            var userInfo = [String: Any]()
            userInfo[NSLocalizedDescriptionKey] = "No suitable sources were found"
            let noSource = NSError(domain: "ErrorDomain", code: HealthKitErrorCode.noSourceAvailable.rawValue, userInfo: userInfo)
            completion(.error(noSource))
        }

        HKHealthStore().execute(sourceQuery)
    }
    
    func isHealthKitAvailable()-> Bool{
        
        guard HKHealthStore.isHealthDataAvailable() else{
            
            return false
        }
        return true
    }
    
    // Bool to check whether any source is available
    func isSourceAvailable() -> Bool{
        
        isHealthDataSourceAvailable = UserDefaults.standard.bool(forKey: "isHealthDataSourceAvailable")
        return isHealthDataSourceAvailable
    }
    
    // Bool to check whether system auth screen is shown
    func isAuthScreenShown() -> Bool{
        isHealthKitAuthScreenShown = UserDefaults.standard.bool(forKey: "isHealthKitAuthScreenShown")
        return isHealthKitAuthScreenShown
    }
    
    func setSourceAvailable(status: Bool){
        
        isHealthDataSourceAvailable = status
        UserDefaults.standard.set(isHealthDataSourceAvailable, forKey: "isHealthDataSourceAvailable")
        
    }
    
    func setAuthScreenShown(status: Bool) {
        isHealthKitAuthScreenShown = status
        UserDefaults.standard.set(isHealthKitAuthScreenShown, forKey: "isHealthKitAuthScreenShown")
    }
    
}
