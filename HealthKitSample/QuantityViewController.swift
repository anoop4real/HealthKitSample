//
//  QuantityViewController.swift
//  HealthKitSample
//
//  Created by anoopm on 05/11/17.
//  Copyright © 2017 anoopm. All rights reserved.
//

import UIKit

class QuantityViewController: UIViewController {
    @IBOutlet private weak var stepLabel:UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
       // self.navigationController?.navigationItem.hidesBackButton = true

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.hidesBackButton = true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func updateLabelWith(text: String){
        
        stepLabel.text = text
    }
    @IBAction func getStepData(){
        
        HealthKitManager.shared().getPreferredSourceFor(identifier: .stepCount) {[weak self] (result) in
            
            switch result {
                
            case .success(let value):
                
                if ((value) != nil){
                    HealthKitManager.shared().getStepCountPerDay(completion: {[weak self](count) in
                        let stepCount = String(Int(count))
                        DispatchQueue.main.async {
                            self?.updateLabelWith(text: stepCount)
                        }                        
                    })
                    //print("Success")
                }else{
                    print("Failed with unknown error")
                    self?.showSettings()
                }
            case .error(let error):
                print("Error occured with reason: \(String(describing: error?.localizedDescription))")
                self?.showSettings()
            }
        }
    }

    func showSettings(){
        
        let appSettingsUrl = URL(string: UIApplicationOpenSettingsURLString)
        if #available(iOS 10.0, *) {
            DispatchQueue.main.async{
                UIApplication.shared.open(appSettingsUrl!, options: [:], completionHandler: nil)
            }
        } else {
            UIApplication.shared.openURL(appSettingsUrl!)
        }
    }

}
