//
//  LandingVC.swift
//  Drively
//
//  Created by Harry Liu on 5/14/18.
//  Copyright © 2018 Harry Liu. All rights reserved.
//

import UIKit
import ZendriveSDK

class LandingVC: UIViewController {
    
    @IBOutlet weak var greetingsLabel: UILabel!
    
    //driver not private since shared between all view controllers
    var driver: Driver?
    private let SIGNIN_VIEW = "signinView"
    private let DEST_VIEW = "destView"
    private let INTRO_VIEW = "introView"

    // MARK: - Used Overridden functions: didLoad, didAppear, prepare
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //if driver has empty string or invalid input parameter
        if (driver!.uName == "" || driver!.sID == "" || Zendrive.isValidInputParameter(driver!.uName) != true || Zendrive.isValidInputParameter(driver!.sID) != true) {
            //create alert and log user out
            callAlert(
                title: "Error",
                message: "Driver ID or School ID not valid. Please enter another Driver ID or School ID! (hint: check for spaces)",
                style: .alert,
                action_title: "Log Out",
                action_style: .default,
                handler: {_ in self.performSegue(withIdentifier: self.SIGNIN_VIEW, sender: nil)} //go to sign in view
            )
            return
        }
        //create user prototype
        let user = Zendriver(fName: driver!.sID, lName: driver!.pword, pNumber: "5109676411", dId: driver!.uName, sId: "school123", sNum: 1, iValue: false)
        
        //check which user logged in
        //self.checkUser(loggedUser: user) not needed for now
        
        //assign user object of type Zendriver to zDriver inside driver object
        driver?.zDriver = user
        
        //display intro if user's first drive
        if (user.sNum == 1 && user.iValue == false) {
            self.intro()
        }
        
        greetingsLabel.text = "Hello, \(driver!.zDriver.fName)! This is session number \(driver!.zDriver.sNum) for you. Let's get started."
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //if going to destination view
        if segue.destination is DestinationVC {
            let destVC = segue.destination as! DestinationVC
            destVC.driver = driver
        }
        //if going to intro view
        if segue.destination is IntroVC {
            let destVC = segue.destination as! IntroVC
            destVC.driver = driver
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Buttons
    @IBAction func goChooseDest(_ sender: Any) {
        //go to destination view
        performSegue(withIdentifier: DEST_VIEW, sender: nil)
    }
    
    @IBAction func logOut(_ sender: Any) {
        //go to sign in view
        performSegue(withIdentifier: SIGNIN_VIEW, sender: nil)
    }
    
    // MARK: - Custom Functions
    func checkUser(loggedUser: Zendriver) {
        //manual detection of user (if implementing app, use firebase or other database)
        if loggedUser.dId == "marissa@zendrive.com" {
            loggedUser.sNum = 6
            loggedUser.fName = "Marissa"
            loggedUser.lName = "Bowman"
            loggedUser.pNumber = "5555555555"
            loggedUser.iValue = true
        } else if loggedUser.dId == "drew@zendrive.com" {
            loggedUser.sNum = 10
            loggedUser.fName = "Drew"
            loggedUser.lName = "Varady"
            loggedUser.pNumber = "5555555555"
            loggedUser.iValue = true
        } else if loggedUser.dId == "adam@zendrive.com" {
            loggedUser.sNum = 20
            loggedUser.fName = "Adam"
            loggedUser.lName = "Ward"
            loggedUser.pNumber = "5555555555"
            loggedUser.iValue = true
        } else if loggedUser.dId == "harryfliu@gmail.com" {
            loggedUser.sNum = 4
            loggedUser.fName = "Harry"
            loggedUser.lName = "Liu"
            loggedUser.pNumber = "5109676411"
            loggedUser.iValue = false
        } else {
            loggedUser.sNum = 1
            loggedUser.fName = "John"
            loggedUser.lName = "Doe"
            loggedUser.pNumber = "5555555555"
            loggedUser.iValue = false
        }
    }
    
    func intro() {
        //go to intro view
        performSegue(withIdentifier: INTRO_VIEW, sender: nil)
    }
    
    // MARK: - custom alert setup
    func callAlert(title: String, message: String, style: UIAlertControllerStyle, action_title: String? = nil, action_style: UIAlertActionStyle? = nil, handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        if let actTitle = action_title {
            if let actStyle = action_style {
                let okay = UIAlertAction(title: actTitle, style: actStyle, handler: handler)
                alert.addAction(okay)
            }
        }
        self.present(alert, animated: true, completion: nil)
    }
}
