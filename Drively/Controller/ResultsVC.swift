//
//  ResultsVC.swift
//  Drively
//
//  Created by Harry Liu on 5/14/18.
//  Copyright © 2018 Harry Liu. All rights reserved.
//

import UIKit
import ZendriveSDK

class ResultsVC: UIViewController, UITableViewDataSource {

    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var resultsTableView: UITableView!
    
    private var lastTripData = [NSArray]()
    private var API_KEY = "Va9d0InqNR6d7TK3W4a26pHt0ay14TIf"
    private var DEST_VIEW = "destinationView"
    private var START_VIEW = "startView"
    private var CELL_LABEL = "Cell"
    var driver: Driver?
    
    // MARK: - Used Overridden functions: didLoad, prepare
    override func viewDidLoad() {
        super.viewDidLoad()
        Zendrive.teardown()
        loadingIndicator.isHidden = true
        resultsTableView.dataSource = self
        getData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is DestinationVC {
            let destVC = segue.destination as! DestinationVC
            destVC.driver = driver
        }
    }
    
    // MARK: - buttons
    @IBAction func reloadAndGet(_ sender: Any) { //this is the phone download emoji on the results view
        //wait 30 seconds and then get data and reload if needed
        callAlert(
            title: "Info",
            message: "Wait a moment while we retrieve your data and refresh the page.",
            style: .alert,
            action_title: "Okay",
            action_style: .default,
            handler: nil
        )
        lastTripData = [NSArray]()
        let when = DispatchTime.now() + 30
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
        DispatchQueue.main.asyncAfter(deadline: when, execute: {
            self.loadingIndicator.isHidden = true
            self.loadingIndicator.stopAnimating()
            self.getData()
        })
    }
    
    @IBAction func logOut(_ sender: Any) {
        //go to sign in view
        performSegue(withIdentifier: START_VIEW, sender: nil)
    }
    
    @IBAction func startNewDrive(_ sender: Any) {
        //go to destination view
        performSegue(withIdentifier: DEST_VIEW, sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lastTripData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = resultsTableView.dequeueReusableCell(withIdentifier: CELL_LABEL)
        
        cell?.textLabel?.text = lastTripData[indexPath.row][0] as? String
        cell?.detailTextLabel?.text = lastTripData[indexPath.row][1] as? String
        
        return cell!
    }
    
    func getData() {
        //url and url request and request method
        let url = "https://api.zendrive.com/v3/driver/\(driver!.zDriver.dId)/trips?apikey=\(API_KEY)"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: nil, delegateQueue: OperationQueue.main)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if error != nil {
                print("Could not fetch data!")
            } else {
                do {
                    //json response: use try and catch
                    let grabbedData = try JSONSerialization.jsonObject(with: data!, options: .mutableLeaves) as! NSDictionary
                    
                    //convert all json to readable elements
                    if (grabbedData.count < 2) {
                        print("Can't find driver ID!")
                    } else {
                        print(grabbedData)
                        let trips = grabbedData["trips"] as! NSArray
                        if trips.count < 1 {
                            self.callAlert(
                                title: "Note",
                                message: "No trips taken or drive doesn't have a fully valid trip yet! May need to also refresh with phone emoji...",
                                style: .alert,
                                action_title: "Okay",
                                action_style: .default,
                                handler: nil
                            )
                        } else{
                            let lastTrip = trips[trips.count - 1] as! NSDictionary
                            let lastTripInfo = lastTrip["info"] as! NSDictionary
                            let lastTripBehavior = lastTrip["driving_behavior"] as! NSDictionary
                            let lastTripScore = lastTripBehavior["score"] as! NSDictionary
                            let lastTripRating = lastTripBehavior["event_rating"] as! NSDictionary
                            
                            let mSpeed = lastTripInfo["trip_max_speed_kmph"] as? Double
                            let distTraveled = lastTripInfo["distance_km"] as? Double
                            let tripDuration = lastTripInfo["duration_seconds"] as? Double
                            let tripID = lastTrip["trip_id"]
                            let tripScore = lastTripScore["zendrive_score"] as? Int
                            let hBrake = lastTripRating["hard_brake_rating"] as? Int
                            let oSpeed = lastTripRating["overspeeding_rating"] as? Int
                            let pUse = lastTripRating["phone_use_rating"] as? Int
                            let rAccel = lastTripRating["rapid_acceleration_rating"] as? Int
                            
                            print(lastTripInfo)
                            print(lastTripBehavior)
                            print(lastTripScore)
                            print(lastTripRating)
                            
                            self.lastTripData.append(["Max Speed in KPH", "\(mSpeed!)"])
                            self.lastTripData.append(["Distance Traveled in KM", "\(distTraveled!)"])
                            self.lastTripData.append(["Trip Duration in Seconds", "\(tripDuration!)"])
                            self.lastTripData.append(["Trip ID", tripID!])
                            self.lastTripData.append(["Trip Score", "\(tripScore!)"])
                            self.lastTripData.append(["Hard Brake Rating", "\(hBrake!)"])
                            self.lastTripData.append(["Over Speed Rating", "\(oSpeed!)"])
                            self.lastTripData.append(["Phone Use Rating", "\(pUse!)"])
                            self.lastTripData.append(["Rapid Acceleration Rating", "\(rAccel!)"])
                            
                            self.resultsTableView.reloadData()
                        }
                    }
                }
                catch {
                    print("Couldn't fetch data!")
                }
            }
        }
        task.resume()
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
