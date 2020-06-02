//
//  LoginViewController.swift
//  LocationBase
//
//  Created by Shane Folden on 6/1/20.
//  Copyright © 2020 Irfan Filipovic. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var submitPassword: UIButton!
    let val = 314
    override func viewDidLoad() {
        super.viewDidLoad()
        
        submitPassword.addTarget(self, action:#selector(self.tappedSubmit), for:.touchUpInside)
        
             backButton.addTarget(self, action:#selector(self.tappedReturn), for:.touchUpInside)
        
        

        // Do any additional setup after loading the view.
    }
    
    @objc func tappedSubmit(){}
    @objc func tappedReturn(){}
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
