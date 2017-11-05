//
//  ViewController.swift
//  HealthKitSample
//
//  Created by anoopm on 04/11/17.
//  Copyright © 2017 anoopm. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if HealthKitManager.shared().isAuthScreenShown(){
            
            self.performSegue(withIdentifier: "gotoStepScreen", sender: nil)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func authorizeHealthKit(){
        
        HealthKitManager.shared().authorizeHealthKit { (result) in
            
            switch result {
                
            case .success(let value):

                if (value){
                    print("Success")
                }else{
                    print("Failed with unknown error")
                }
            case .error(let error):
                print("Error occured with reason: \(error.localizedDescription)")
            }
        }
    }
    


}

