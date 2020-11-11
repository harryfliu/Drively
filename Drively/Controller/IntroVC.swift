//
//  IntroVC.swift
//  Drively
//
//  Created by Harry Liu on 5/14/18.
//  Copyright © 2018 Harry Liu. All rights reserved.
//

import UIKit

class IntroVC: UIViewController {

    var driver: Driver?
    private var SIGNIN_VIEW = "signInView"
    private var DEST_VIEW = "destView"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Used Overridden prepare function
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //if going to destination view
        if segue.destination is DestinationVC {
            let destVC = segue.destination as! DestinationVC
            destVC.driver = driver
        }
    }
    
    // MARK: - Buttons
    @IBAction func goToDestination(_ sender: Any) {
        //go to destination view
        performSegue(withIdentifier: DEST_VIEW, sender: nil)
    }
    
    @IBAction func logOut(_ sender: Any) {
        //go to sign in view
        performSegue(withIdentifier: SIGNIN_VIEW, sender: nil)
    }
}
