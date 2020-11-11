//
//  Driver.swift
//  Drively
//
//  Created by Harry Liu on 5/14/18.
//  Copyright © 2018 Harry Liu. All rights reserved.
//
//  Driver class to store database app-side driver data, needs to go to a DB like firebase

import Foundation

class Driver {
    private var _userName = ""
    private var _password = ""
    private var _schoolID = ""
    private var _zenDriver: Zendriver?
    
    //get and set individual driver values
    var uName: String {
        get {
            return _userName
        }
        set {
            _userName = newValue
        }
    }
    
    var pword: String {
        get {
            return _password
        }
        set {
            _password = newValue
        }
    }
    
    var sID: String {
        get {
            return _schoolID
        }
        set {
            _schoolID = newValue
        }
    }
    
    var zDriver: Zendriver {
        get {
            return _zenDriver!
        }
        set {
            _zenDriver = newValue
        }
    }
}

