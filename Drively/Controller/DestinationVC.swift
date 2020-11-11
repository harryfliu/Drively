//
//  DestinationVC.swift
//  Drively
//
//  Created by Harry Liu on 5/14/18.
//  Copyright © 2018 Harry Liu. All rights reserved.
//
//TODO:
// - test SDK initialization
// - no need for passing variables through segues anymore, adjust

import Foundation
import UIKit
import MapKit
import CoreLocation
import ZendriveSDK //start all SDK operations here and see if need to pass to pre-result
import ZendriveSDK.Insurance
import Firebase

class DestinationVC: UIViewController, ZendriveDelegateProtocol {
    
    @IBOutlet weak var destinationName: UITextField!
    @IBOutlet weak var whereTo: UILabel!
    @IBOutlet weak var startDriveButton: UIButton!
    @IBOutlet weak var stopDriveButton: UIButton!
    @IBOutlet weak var introButton: UIBarButtonItem!
    @IBOutlet weak var pickupLabel: UILabel!
    @IBOutlet weak var inVehicleLabel: UILabel!
    @IBOutlet weak var logInButton: UIBarButtonItem!
    @IBOutlet weak var logOutButton: UIBarButtonItem!
    @IBOutlet weak var exitButton: UIBarButtonItem!
    
    private let PRERESULTS_VIEW = "PreResultsView"
    private let SIGNIN_VIEW = "signinView"
    private let INTRO_VIEW = "introView"
    
    private var isZendriveSetup: Bool?
    private var ZendriveSDKKey: String = ""
    private var DriveDetectionModeKey: Int32 = 1 //manual drive mode
    private var ZendriveServiceLevelNum: Int32 = 0 //default service level
    private var locations = [MKPointAnnotation]()
    var ref: DatabaseReference!
    var driver: Driver?
    var analyzedInfo: ZendriveAnalyzedDriveInfo?
    var sdkStatus: Bool?
    
    //on first call, set up variable as location manager
    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        //prompt for authorization
        manager.requestAlwaysAuthorization()
        return manager
    }()
    
    // MARK: - Used Overridden functions: didLoad, didAppear, prepare
    override func viewDidLoad() {
        super.viewDidLoad()
        isZendriveSetup = false
        introButton.isEnabled = true
        stopDriveButton.isEnabled = false
        exitButton.isEnabled = false
        
        //set toolbar with done button
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneClicked))
        
        toolBar.setItems([flexSpace, doneButton], animated: true)
        destinationName.inputAccessoryView = toolBar
        whereTo.text = "Where to, \(driver!.zDriver.fName)?"
        pickupLabel.text = String(ZendriveManager.sharedInstance.waitForPassengers)
        inVehicleLabel.text = String(ZendriveManager.sharedInstance.pInCar)
        logInButton.isEnabled = false
        logOutButton.isEnabled = true
        ref = Database.database().reference()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.startZendrive()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //if going to preresult view
        if segue.destination is PreResultVC {
            let destVC = segue.destination as! PreResultVC
            destVC.driver = driver
            destVC.analyzedInfo = analyzedInfo
        }
        //if going to intro view
        if segue.destination is IntroVC {
            Zendrive.teardown()
            let destVC = segue.destination as! IntroVC
            destVC.driver = driver
        }
    }
    
    // MARK: - Buttons
    @IBAction func userInfo(_ sender: Any) {
        callAlert(
            title: "Info",
            message: "Name: \(driver!.zDriver.fName) \(driver!.zDriver.lName) Driver ID: \(driver!.zDriver.dId) School ID: \(driver!.zDriver.sId)",
            style: .alert,
            action_title: "Okay",
            action_style: .default,
            handler: nil
        )
    }
    
    @IBAction func startDrive(_ sender: Any) {
        locationManager.startUpdatingLocation()
        callAlert(
            title: "Note",
            message: "After your driving session, come back to Drively to stop drive and see your session results.",
            style: .alert,
            action_title: "Okay",
            action_style: .default,
            handler: {_ in self.openMap()}
        )
    }
    
    @IBAction func stopDrive(_ sender: Any) {
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
        ZendriveManager.sharedInstance.stopPlease()
        callAlert(title: "Hey, hey, hey", message: "The drive has stopped. Nice, you did it buddy.")
        //go to pre-results view
        //performSegue(withIdentifier: self.PRERESULTS_VIEW, sender: nil)
    }
    
    @IBAction func showAnalyzedInfo(_ sender: Any) {
        if let aInfo = ZendriveManager.sharedInstance.aInfo {
            self.ref.child("analyzed_drives").child(driver!.zDriver.dId).child("start_time").setValue(aInfo.startTimestamp)
            self.ref.child("analyzed_drives").child(driver!.zDriver.dId).child("end_time").setValue(aInfo.endTimestamp)
            self.ref.child("analyzed_drives").child(driver!.zDriver.dId).child("average_speed").setValue(aInfo.averageSpeed)
            self.ref.child("analyzed_drives").child(driver!.zDriver.dId).child("distance").setValue(aInfo.distance)
            self.ref.child("analyzed_drives").child(driver!.zDriver.dId).child("drive_type").setValue(aInfo.driveType.rawValue)
            self.ref.child("analyzed_drives").child(driver!.zDriver.dId).child("tracking_id").setValue(aInfo.trackingId)
            self.ref.child("analyzed_drives").child(driver!.zDriver.dId).child("average_speed").setValue(aInfo.averageSpeed)
            callAlert(
                title: "Analyzed Drive Details",
                message: "Start drive time: \(aInfo.startTimestamp) Average speed: \(aInfo.averageSpeed) Distance: \(aInfo.distance) Type of drive: \(aInfo.driveType.rawValue) User ID: \(driver!.zDriver.dId)",
                style: .alert,
                action_title: "Okay",
                action_style: .default,
                handler: nil
            )
        }
        else {
            callAlert(
                title: "Not Available",
                message: "Trip not analyzed!",
                style: .alert,
                action_title: "Aw man.",
                action_style: .default,
                handler: nil
            )
        }
    }
    
    @IBAction func logIn(_ sender: Any) {
        ZendriveManager.sharedInstance.aDriver = true
        updateTrackingID()
        ZendriveManager.sharedInstance.updateInsurancePeriod()
        locationManager.startUpdatingLocation()
        logInButton.isEnabled = false
        logOutButton.isEnabled = true
    }
    
    @IBAction func logOut(_ sender: Any) {
        ZendriveManager.sharedInstance.aDriver = false
        ZendriveManager.sharedInstance.pInCar = 0
        ZendriveManager.sharedInstance.waitForPassengers = 0
        updatePassengerText()
        updateTrackingID()
        locationManager.stopUpdatingLocation()
        //ZendriveManager.sharedInstance.updateInsurancePeriod()
        logOutButton.isEnabled = false
        logInButton.isEnabled = true
        exitButton.isEnabled = true
        //Zendrive.teardown()
        //go to sign in view
        //performSegue(withIdentifier: SIGNIN_VIEW, sender: nil)
    }
    
    @IBAction func exitToSignIn(_ sender: Any) {
        ZendriveManager.sharedInstance.shutItAllDown()
        performSegue(withIdentifier: SIGNIN_VIEW, sender: nil)
    }
    
    @IBAction func goIntro(_ sender: Any) {
        //go to intro view
        //performSegue(withIdentifier: INTRO_VIEW, sender: nil) not anymore
    }
    
    @IBAction func acceptRequest(_ sender: Any) {
        ZendriveManager.sharedInstance.waitForPassengers += 1
        updatePassengerText()
        updateTrackingID()
        ZendriveManager.sharedInstance.updateInsurancePeriod()
    }
    
    @IBAction func cancelRequest(_ sender: Any) {
        if (ZendriveManager.sharedInstance.waitForPassengers > 0) {
            ZendriveManager.sharedInstance.waitForPassengers -= 1
            updatePassengerText()
            updateTrackingID()
            ZendriveManager.sharedInstance.updateInsurancePeriod()
        }
        else {
            callAlert(title: "Note", message: "There's no more passengers to cancel on. Go find yourself some more before you cancel please. Pretty please.", style: .alert, action_title: "Fine", action_style: .default, handler: nil)
        }
    }
    
    @IBAction func pickUp(_ sender: Any) {
        if (ZendriveManager.sharedInstance.waitForPassengers > 0){
            ZendriveManager.sharedInstance.pInCar += 1
            ZendriveManager.sharedInstance.waitForPassengers -= 1
            updatePassengerText()
            updateTrackingID()
            ZendriveManager.sharedInstance.updateInsurancePeriod()
        }
        else {
            callAlert(
                title: "Excuse me...",
                
                message: "You don't have any passengers to pick up. Please accept a request first."
            )
        }
    }
    
    @IBAction func dropOff(_ sender: Any) {
        if (ZendriveManager.sharedInstance.pInCar > 0){
            ZendriveManager.sharedInstance.pInCar -= 1
            updatePassengerText()
            updateTrackingID()
            ZendriveManager.sharedInstance.updateInsurancePeriod()
        }
        else {
            callAlert(
                title: "Excuse me...",
                message: "You don't have any more passengers to drop off. Please accept a request first."
            )
        }
    }
    
    
    // MARK: - done clicked for toolbar
    @objc func doneClicked() {
        view.endEditing(true)
    }
    
    @IBAction func uploadDebugData(_ sender: Any) {
        ZendriveManager.sharedInstance.debugMe(currUser: driver!.zDriver)
    }
    
    func updatePassengerText() {
        self.pickupLabel.text = String(ZendriveManager.sharedInstance.waitForPassengers)
        self.inVehicleLabel.text = String(ZendriveManager.sharedInstance.pInCar)
    }
    
    func updateTrackingID() {
        if (ZendriveManager.sharedInstance.pInCar > 0 || ZendriveManager.sharedInstance.waitForPassengers > 0) {
            if (ZendriveManager.sharedInstance.tID == nil) {
                ZendriveManager.sharedInstance.tID = String(arc4random_uniform(9999))
            }
        }
        else {
            if (ZendriveManager.sharedInstance.tID != nil) {
                ZendriveManager.sharedInstance.tID = nil
            }
        }
    }
    
    @IBAction func pressPeriod1(_ sender: Any) {
        ZendriveManager.sharedInstance.testPeriod1()
    }
    
    @IBAction func pressPeriod2(_ sender: Any) {
        ZendriveManager.sharedInstance.testPeriod2()
    }
    
    @IBAction func pressPeriod3(_ sender: Any) {
        ZendriveManager.sharedInstance.testPeriod3()
    }
    
    @IBAction func pressStopPeriod(_ sender: Any) {
        ZendriveManager.sharedInstance.testStopPeriod()
    }
    
    // MARK: - open map
    func openMap() {
        //use mapkit and core location and natural language query to find wanted destination
        let startCoordinates = CLLocationCoordinate2DMake(37.337989, -121.884989) //center search around san jose
        let distance: CLLocationDistance = 1000
        let searchRequest = MKLocalSearchRequest()
        searchRequest.naturalLanguageQuery = destinationName.text
        searchRequest.region = MKCoordinateRegionMakeWithDistance(startCoordinates, distance, distance)
        
        let currSearch = MKLocalSearch(request: searchRequest)
        currSearch.start(completionHandler: {(response, error) in
            if response == nil {
                self.callAlert(
                    title: "Error",
                    message: "Please enter a valid search item for your destination.",
                    style: .alert,
                    action_title: "Okay",
                    action_style: .default,
                    handler: nil
                )
            } else {
                let latitude = response?.boundingRegion.center.latitude
                let longitude = response?.boundingRegion.center.longitude
                let coordinates = CLLocationCoordinate2DMake(latitude!, longitude!)
                let distance: CLLocationDistance = 1000
                let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, distance, distance)
                let options = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center), MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)]
                if let valid = response {
                    if valid.mapItems.count > 0 {
                        let mapItem = valid.mapItems[0]
                        if(mapItem.openInMaps(launchOptions: options)){
                            //if Zendrive.isValidInputParameter(self.driver!.zDriver.sId) == true { //should be true at this point but just double checking
                                //Zendrive.startDrive(self.driver!.zDriver.sId) //tracking id
                            //}
                            ZendriveManager.sharedInstance.updateTrackingID()
                            ZendriveManager.sharedInstance.drivePlease()
                            self.introButton.isEnabled = false
                            self.stopDriveButton.isEnabled = true
                            self.startDriveButton.isEnabled = false
                            print("Maps opened successfully!")
                        } else {
                            print("Something is definitely wrong with opening Maps.")
                        }
                    }
                } else {
                    let placemark = MKPlacemark(coordinate: coordinates)
                    let mapItem = MKMapItem(placemark: placemark)
                    if(mapItem.openInMaps(launchOptions: options)){
//                        if Zendrive.isValidInputParameter(self.driver!.zDriver.sId) == true { //should be true at this point but just double checking
//                            Zendrive.startDrive(self.driver!.zDriver.sId) //tracking id
//                        }
                        ZendriveManager.sharedInstance.updateTrackingID()
                        ZendriveManager.sharedInstance.drivePlease()
                        self.introButton.isEnabled = false
                        self.stopDriveButton.isEnabled = true
                        self.startDriveButton.isEnabled = false
                        print("Maps opened successfully!")
                    } else {
                        print("Something is definitely wrong with opening Maps.")
                    }
                }
            }
        })
    }
    
    // MARK: - zendrive SDK setup functions
    func startZendrive() {
        if (self.isZendriveSetup != true){
            print("Your driver ID: \(driver!.zDriver.dId)")
            ZendriveManager.sharedInstance.aDriver = true //from the first log in screen - for initialization
            ZendriveManager.sharedInstance.initializeZendriveSDK(currUser: driver!.zDriver)
            //locationManager.startUpdatingLocation()
//            self.setupZendriveSDK(currUser: driver!.zDriver, successBlock: {
//                () -> Void in
//                    self.isZendriveSetup = true
//                    print("Zendrive initialized successfully!")
//                }, failureBlock: { (err: NSError) -> Void in
//                    print("Zendrive failed to initialize!")
//                }
//            )
        }
        //self.sdkStatus = Zendrive.isSDKSetup()
    }
    
//    func setupZendriveSDK(currUser: Zendriver, successBlock: @escaping () -> Void, failureBlock: @escaping (NSError) -> Void) {
//        let configuration = ZendriveConfiguration()
//        configuration.applicationKey = self.ZendriveSDKKey
//
//        let driveDetectionMode: ZendriveDriveDetectionMode = ZendriveDriveDetectionMode(rawValue: self.DriveDetectionModeKey)! //manual drive mode
//        configuration.driveDetectionMode = driveDetectionMode
//
//        configuration.driverId = currUser.dId
//
//        let driverAttrs = ZendriveDriverAttributes()
//
//        let firstName = currUser.fName
//        if (firstName.count > 0) {
//            driverAttrs.setFirstName(firstName)
//        }
//
//        let lastName = currUser.lName
//        if (lastName.count > 0) {
//            driverAttrs.setLastName(lastName)
//        }
//
//        let phoneNumber = currUser.pNumber;
//        if (phoneNumber.count > 0) {
//            driverAttrs.setPhoneNumber(phoneNumber)
//        }
//
//        let serviceLevel = self.ZendriveServiceLevelNum
//        driverAttrs.setServiceLevel(ZendriveServiceLevel(rawValue: serviceLevel)!)
//
//        configuration.driverAttributes = driverAttrs
//
//        Zendrive.setup(with: configuration, delegate: self, completionHandler: {
//            (success: Bool, error: NSError) -> Void in
//                if(success == true) {
//                    successBlock()
//                } else {
//                    failureBlock(error)
//                }
//            } as? ZendriveSetupHandler)
//    }
    
    // MARK: - custom alert setup
    func callAlert(title: String, message: String, style: UIAlertControllerStyle = .alert, action_title: String? = "Okay", action_style: UIAlertActionStyle? = .default, handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        if let actTitle = action_title {
            if let actStyle = action_style {
                let okay = UIAlertAction(title: actTitle, style: actStyle, handler: handler)
                alert.addAction(okay)
            }
        }
        self.present(alert, animated: true, completion: nil)
    }
    
//    // MARK: - Delegate Calls
//    func processStart(ofDrive startInfo: ZendriveDriveStartInfo) {
//        print("Drive started!")
//    }
//
//    func processEnd(ofDrive estimatedDriveInfo: ZendriveEstimatedDriveInfo) {
//        print("Drive ended!")
//    }
//
//    func processAnalysis(ofDrive analyzedDriveInfo: ZendriveAnalyzedDriveInfo) {
//        print("Drive analyzed!")
//        self.analyzedInfo = analyzedDriveInfo
//    }
//
//    func processLocationDenied() {
//        print("User disallowed location access to SDK.")
//    }
//
//    func processLocationApproved() {
//        print("User allowed location access to SDK.")
//    }
}

extension DestinationVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let recentLocation = locations.last
        if UIApplication.shared.applicationState == .active {
            print("Drively in foreground. Currently at \(recentLocation!)")
        } else {
            print("Drively is in background. Currently at \(recentLocation!)")
        }
    }
}
