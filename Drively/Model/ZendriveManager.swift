//
//  ZendriveManager.swift
//  Drively
//
//  Created by Harry Liu on 9/7/18.
//  Copyright © 2018 Harry Liu. All rights reserved.
//

import Foundation
import ZendriveSDK.Insurance
import UIKit

//import ZendriveSDKTesting

class InsurancePeriod {
    //object variables
    private let _period: Int
    
    //initialize object
    init(period: Int){
        self._period = period
    }
    
    var period: Int {
        get {
            return _period
        }
    }
}

class ZendriveManager: NSObject, ZendriveDelegateProtocol, ZendriveDebugDelegateProtocol {
    
    private var _activeDriver: Bool = false
    private var _passengersInCar: Int = 0
    private var _waitingForPassengers: Int = 0
    private var _analyzedInfo: ZendriveAnalyzedDriveInfo?
    private var _trackingID: String? = nil
    private let _sdkKey: String = "H1R9JIKtUTgxAHW8d8Jmm8sjSVuXirXj"
    public static let sharedInstance: ZendriveManager = ZendriveManager()
    
    var aDriver: Bool {
        get {
            return _activeDriver
        }
        set {
            _activeDriver = newValue
        }
    }
    
    var pInCar: Int {
        get {
            return _passengersInCar
        }
        set {
            _passengersInCar = newValue
        }
    }
    
    var waitForPassengers: Int {
        get {
            return _waitingForPassengers
        }
        set {
            _waitingForPassengers = newValue
        }
    }
    
    var aInfo: ZendriveAnalyzedDriveInfo? {
        get {
            if let analyzedInfo = _analyzedInfo {
                return analyzedInfo
            }
            else {
                return nil
            }
        }
    }
    
    var tID: String? {
        get {
            if let trackID = _trackingID {
                return trackID
            }
            else {
                return nil
            }
        }
        set {
            _trackingID = newValue
        }
    }
    
    public func currentlyActiveInsurancePeriod() -> InsurancePeriod? {
        if (_activeDriver == false) {
            return nil
        }
        else if (_passengersInCar > 0){
            return InsurancePeriod.init(period: 3)
        }
        else if (_waitingForPassengers > 0){
            return InsurancePeriod.init(period: 2)
        }
        else {
            return InsurancePeriod.init(period: 1)
        }
    }
    
    public func initializeZendriveSDK(currUser: Zendriver){
        let zendriveConfig = ZendriveConfiguration()
        zendriveConfig.applicationKey = _sdkKey
        
        let validOrNot = Zendrive.isValidInputParameter(currUser.dId)
        print("The driver ID is: \(validOrNot)")
        
        zendriveConfig.driverId = currUser.dId
        zendriveConfig.driveDetectionMode = ZendriveDriveDetectionMode.autoON
//            ZendriveDriveDetectionMode.autoON:
//            ZendriveDriveDetectionMode.autoOFF
        //zendriveConfig.driveDetectionMode = ZendriveDriveDetectionMode.autoOFF
        
        let driverAttrs = ZendriveDriverAttributes()
        let firstName = currUser.fName
        if (firstName.count > 0) {
            driverAttrs.setFirstName(firstName)
        }
        
        let lastName = currUser.lName
        if (lastName.count > 0) {
            driverAttrs.setLastName(lastName)
        }
        
        let phoneNumber = currUser.pNumber;
        if (phoneNumber.count > 0) {
            driverAttrs.setPhoneNumber(phoneNumber)
        }
        
        zendriveConfig.driverAttributes = driverAttrs
        
        Zendrive.setup(with: zendriveConfig, delegate: self) { (success, error) in
            let error: NSError? = error as NSError?
            if(error != nil) {
                print("[ZendriveManager]: setupWithConfiguration:error:" +
                    " \(String(describing: error!.localizedFailureReason))")
            }
            else {
                print("[ZendriveManager]: setupWithConfiguration:success")
                //let activeInsurancePeriod: InsurancePeriod? = self.currentlyActiveInsurancePeriod()
//                if (activeInsurancePeriod != nil) {
//                    Zendrive.setDriveDetectionMode(ZendriveDriveDetectionMode.autoON)
//                }
                //self.updateInsurancePeriod()
            }
        }
    }
    
    public func updateInsurancePeriod() {
        let activeInsurancePeriod: InsurancePeriod? = currentlyActiveInsurancePeriod()
        var error: NSError? = nil
        if (activeInsurancePeriod == nil){
            print("The current insurance period is not valid. How can that be?")
            ZendriveInsurance.stopPeriod(&error)
        }
        else if (activeInsurancePeriod?.period == nil) {
            ZendriveInsurance.stopPeriod(&error)
        }
        else if (activeInsurancePeriod!.period == 1) {
            ZendriveInsurance.startPeriod1(&error)
        }
        else if (activeInsurancePeriod!.period == 2) {
            ZendriveInsurance.startDrive(withPeriod2: _trackingID, error: &error)
        }
        else if (activeInsurancePeriod!.period == 3) {
            ZendriveInsurance.startDrive(withPeriod3: _trackingID, error: &error)
        }
    }
    
    public func drivePlease() {
        //Zendrive.startDrive(_trackingID!)
        //let mockDriveBuilder = ZendriveMockDriveBuilder()
    }
    
    public func stopPlease() {
        Zendrive.stopManualDrive()
    }
    
    public func shutItAllDown() {
        Zendrive.teardown(completionHandler: nil)
    }
    
    public func updateTrackingID() {
        ZendriveManager.sharedInstance.tID = String(arc4random_uniform(9999))
    }
    
    public func testPeriod1() {
        var error: NSError? = nil
        ZendriveInsurance.startPeriod1(&error)
        print(error as Any)
    }
    
    public func testPeriod2() {
        var error: NSError? = nil
        ZendriveInsurance.startDrive(withPeriod2: "testingPeriod2", error: &error)
        print(error as Any)
    }
    
    public func testPeriod3() {
        var error: NSError? = nil
        ZendriveInsurance.startDrive(withPeriod3: "testingPeriod3", error: &error)
        print(error as Any)
    }
    
    public func testStopPeriod() {
        var error: NSError? = nil
        ZendriveInsurance.stopPeriod(&error)
        print(error as Any)
    }
    
    public func debugMe(currUser: Zendriver) {
        let zendriveConfig = ZendriveConfiguration()
        zendriveConfig.applicationKey = _sdkKey
        
        zendriveConfig.driverId = currUser.dId
        zendriveConfig.driveDetectionMode = ZendriveDriveDetectionMode.autoOFF
        
        let driverAttrs = ZendriveDriverAttributes()
        let firstName = currUser.fName
        if (firstName.count > 0) {
            driverAttrs.setFirstName(firstName)
        }
        
        let lastName = currUser.lName
        if (lastName.count > 0) {
            driverAttrs.setLastName(lastName)
        }
        
        let phoneNumber = currUser.pNumber;
        if (phoneNumber.count > 0) {
            driverAttrs.setPhoneNumber(phoneNumber)
        }
        
        zendriveConfig.driverAttributes = driverAttrs
        ZendriveDebug.uploadAllZendriveData(with: zendriveConfig, delegate: self)
    }
    
    func zendriveDebugUploadFinished(_ status: ZendriveDebugUploadStatus) {
        print("Zendrive Debug Upload code: \(status.rawValue)")
    }
    
    // MARK: - Delegate Calls
    func processStart(ofDrive startInfo: ZendriveDriveStartInfo) {
        print("Drive started!")
    }
    
    func processEnd(ofDrive estimatedDriveInfo: ZendriveEstimatedDriveInfo) {
        print("Drive ended!")
    }
    
    func processAnalysis(ofDrive analyzedDriveInfo: ZendriveAnalyzedDriveInfo) {
        print("Drive analyzed!")
        _analyzedInfo = analyzedDriveInfo
    }
    
    func processLocationDenied() {
        print("User disallowed location access to SDK.")
    }
    
    func processLocationApproved() {
        print("User allowed location access to SDK.")
    }
}
