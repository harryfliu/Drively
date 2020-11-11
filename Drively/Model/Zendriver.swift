//
//  ZenDriver.swift
//  Drively
//
//  Created by Harry Liu on 5/14/18.
//  Copyright © 2018 Harry Liu. All rights reserved.
//
//  Zendriver class to store data relevant to initialize Zendrive SDK

import Foundation

class Zendriver {
    //default values for Zendrive user, get actual values from Firebase or other database in
    //practice
    private var _firstName = "Ayrton"
    private var _lastName = "Senna"
    private var _phoneNumber = "5555555555"
    private var _driverId = "senna@formuala.com"
    private var _schoolId = "abc123"
    private var _sessionNumber = 3
    private var _introValue = false
    
    //initialize Zendriver (user)
    init(fName: String, lName: String, pNumber: String, dId: String, sId: String, sNum: Int, iValue: Bool){
        self._firstName = fName
        self._lastName = lName
        self._phoneNumber = pNumber
        self._driverId = dId
        self._schoolId = sId
        self._sessionNumber = sNum
        self._introValue = iValue
    }
    
    //get and set individual zendrive user values
    var fName: String {
        get {
            return _firstName
        }
        set {
            _firstName = newValue
        }
    }
    
    var lName: String {
        get {
            return _lastName
        }
        set {
            _lastName = newValue
        }
    }
    
    var pNumber: String {
        get {
            return _phoneNumber
        }
        set {
            _phoneNumber = newValue
        }
    }
    
    var dId: String {
        get {
            return _driverId
        }
        set {
            _driverId = newValue
        }
    }
    
    var sId: String {
        get {
            return _schoolId
        }
        set {
            _schoolId = newValue
        }
    }
    
    var sNum: Int {
        get {
            return _sessionNumber
        }
        set {
            _sessionNumber = newValue
        }
    }
    
    var iValue: Bool {
        get {
            return _introValue
        }
        set {
            _introValue = newValue
        }
    }
    
}
