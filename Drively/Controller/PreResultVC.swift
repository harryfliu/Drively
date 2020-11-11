//
//  PreResultVC.swift
//  Drively
//
//  Created by Harry Liu on 5/14/18.
//  Copyright © 2018 Harry Liu. All rights reserved.
//

import UIKit
import ZendriveSDK

class PreResultVC: UIViewController {
    
    @IBOutlet weak var callBacktxt: UIButton!
    @IBOutlet weak var seeResultsText: UIButton!
    @IBOutlet weak var displayText: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var activityText: UILabel!
    
    private let RESULTS_VIEW = "resultsView"
    var driver: Driver?
    var analyzedInfo: ZendriveAnalyzedDriveInfo?
    
    // MARK: - Used Overridden functions: didLoad, prepare
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.isHidden = true
        activityText.isHidden = true
        displayText.text = "Good job, \(driver!.zDriver.fName)! Now check your results."
    }
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //if going to results view
        if segue.destination is ResultsVC {
            let destVC = segue.destination as! ResultsVC
            destVC.driver = driver
        }
    }
    
    // MARK: - seeResults button
    @IBAction func seeResults(_ sender: Any) {
        //turn on waiting text and create delay for 30 seconds
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        activityText.isHidden = false
        let when = DispatchTime.now() + 30 //wait long enough for api to update information for worst case scenario
        seeResultsText.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: when, execute: {
            self.activityText.isHidden = true
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
            //go to results view
            self.performSegue(withIdentifier: self.RESULTS_VIEW, sender: nil)
        })
    }
    
    @IBAction func callBackPush(_ sender: Any) {
        callAlert(
            title: "Analyzed Drive Details",
            message: "Start drive time: \(analyzedInfo?.startTimestamp)",
            style: .alert,
            action_title: "Okay",
            action_style: .default, handler: nil
        )
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
