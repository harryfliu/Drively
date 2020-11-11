//
//  ViewController.swift
//  Drively
//
//  Created by Harry Liu on 5/14/18.
//  Copyright © 2018 Harry Liu. All rights reserved.
//

import UIKit

class SignInVC: UIViewController {
    
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var schoolID: UITextField!
    
    private let LANDING_VIEW = "LandingVC"
    
    // MARK: - Used Overridden functions: didLoad, prepare
    override func viewDidLoad() {
        super.viewDidLoad()
        //configure toolbar for done button
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneClicked))
        
        toolBar.setItems([flexSpace, doneButton], animated: true)
        
        userName.inputAccessoryView = toolBar
        password.inputAccessoryView = toolBar
        schoolID.inputAccessoryView = toolBar
        //have text for password field obsfucated
        password.isSecureTextEntry = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //if going to landing page view
        if segue.destination is LandingVC {
            let destVC = segue.destination as! LandingVC
            
            destVC.driver = Driver()
            
            let name = userName.text!
            let key = password.text!
            let school = schoolID.text!
            
            //check if name, password, or school id are not empty strings
            //if empty string, print and don't set class variable
            if name != "" {
                destVC.driver?.uName = name
            } else {
                print("No username entered!")
            }
            if key != "" {
                destVC.driver?.pword = key
            } else {
                print("No password entered!")
            }
            if school != "" {
                destVC.driver?.sID = school
            } else {
                print("No school ID entered!")
            }
            print("Got here!")
        }
    }
    
    // MARK: - done clicked for toolbar
    @objc func doneClicked() {
        view.endEditing(true)
    }
    
    // MARK: - Buttons
    @IBAction func logIn(_ sender: UIButton) {
        //go to landing view
        performSegue(withIdentifier: LANDING_VIEW, sender: nil)
    }
    
    @IBAction func signUp(_ sender: UIButton) {
        //fill in and send to database for actual app implementation
    }
    
}

