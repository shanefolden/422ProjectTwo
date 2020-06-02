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
        
       
        
        

        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(animated)
        submitPassword.addTarget(self, action:#selector(self.tappedSubmit), for:.touchUpInside)
               
                    backButton.addTarget(self, action:#selector(self.tappedReturn), for:.touchUpInside)
        
    }
  
    func switchScreen() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        if let viewController = mainStoryboard.instantiateViewController(withIdentifier: "DevModeViewController") as? UIViewController {
            self.present(viewController, animated: true, completion: nil)
        }
    }
    
    
    @objc func tappedSubmit(){
        if (passwordField.text == String(val))
        {
            
          switchScreen()
        }
        else{
            print("unsicko")
        }
    }
   @objc func tappedReturn(){
        //pops current view off stack which brings user back to main page
        navigationController?.popViewController(animated: true)
        //Animates Transition
        dismiss(animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
