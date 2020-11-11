//
//  ZendriveTripData.swift
//  Drively
//
//  Created by Harry Liu on 5/14/18.
//  Copyright © 2018 Harry Liu. All rights reserved.
//
//  ZendriveTripData class to store zendrive data from call back and upload to firebase
//  for this implementation of Drively, this class isn't used but may be useful in the future

import Foundation

class ZendriveTripData {
    private var _maxSpeedKPH = ""
    private var _distanceTraveled = ""
    private var _hardBrakeRating = ""
    private var _overSpeedRating = ""
    private var _phoneUseRating = ""
    private var _rapidAccelRating = ""
    private var _tripDuration = ""
    private var _tripScore = ""
    private var _tripID = ""
    
    init(mSpeed: String, distTraveled: String, hBrake: String, oSpeed: String, pUse: String, rAccel: String, tripDuration: String, tripScore: String, tripID: String) {
        self._maxSpeedKPH = mSpeed
        self._distanceTraveled = distTraveled
        self._hardBrakeRating = hBrake
        self._overSpeedRating = oSpeed
        self._phoneUseRating = pUse
        self._rapidAccelRating = rAccel
        self._tripDuration = tripDuration
        self._tripScore = tripScore
        self._tripID = tripID
    }
    
    var mSpeed: String {
        get {
            return _maxSpeedKPH
        }
        set {
            _maxSpeedKPH = newValue
        }
    }
    
    var distTraveled: String {
        get {
            return _distanceTraveled
        }
        set {
            _distanceTraveled = newValue
        }
    }
    
    var hBrake: String {
        get {
            return _hardBrakeRating
        }
        set {
            _hardBrakeRating = newValue
        }
    }
    
    var oSpeed: String {
        get {
            return _overSpeedRating
        }
        set {
            _overSpeedRating = newValue
        }
    }
    
    var pUse: String {
        get {
            return _phoneUseRating
        }
        set {
            _phoneUseRating = newValue
        }
    }
    
    var rAccel: String {
        get {
            return _rapidAccelRating
        }
        set {
            _rapidAccelRating = newValue
        }
    }
    
    var tripDuration: String {
        get {
            return _tripDuration
        }
        set {
            _tripDuration = newValue
        }
    }
    
    var tripScore: String {
        get {
            return _tripScore
        }
        set {
            _tripScore = newValue
        }
    }
    
    var tripID: String {
        get {
            return _tripID
        }
        set {
            _tripID = newValue
        }
    }
}
