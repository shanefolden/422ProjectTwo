//
//  SecondViewController.swift
//  LocationBase
//
//  Created by Shane Folden on 5/30/20.
//  Copyright © 2020 Irfan Filipovic. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications
import MapKit

class SecondViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, MKLocalSearchCompleterDelegate, UITextFieldDelegate  {
     
    // Selectable data for minute Picker
    let pickerData = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120]
    // Button to submit form
    @IBOutlet weak var submitButton: UIButton!
    //Text field to enter the address
    @IBOutlet weak var addressForm: UITextField!
    //Variable for the minute selecter in line time form
    @IBOutlet weak var picker: UIPickerView!
    //Button that returns user to home screen
    @IBOutlet weak var returnButton: UIButton!
    
    
    //Objects that format date before it is send to database
    let dateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    //Initialize amount of minutes
    var minutes = -1
    
    // Function that initializes the amount of objects in the minute picker
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    //Function that initializes the amount of rows in the minute picker
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    //Function that closes the ios keyboard when the enter key is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    //Function that does initial set up before loading the view
    override func viewDidLoad() {
        super.viewDidLoad()
        //Initialize date format
        dateFormatter.dateFormat = "yyyy-MM-dd"
        // Time Formatting
        timeFormatter.dateStyle = .none
        timeFormatter.dateFormat = "HH:mm:ss"
        //Initialize address textField with a place holder
        self.addressForm.delegate = self
        addressForm.placeholder = "Business Address"
        
        // Create a target function called when submit button is pressed
        submitButton.addTarget(self, action:#selector(self.tappedSubmit), for:.touchUpInside)
         // Create a target function called when return button is pressed
         returnButton.addTarget(self, action:#selector(self.tappedReturn), for:.touchUpInside)
        
        //Initialize minute picker with the correct data source
        self.picker.delegate = self
        self.picker.dataSource = self

      
    }
    
   
   
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        minutes = Int(pickerData[row])
        return String(pickerData[row])
    }
    
    //Alert function if address is invalid
    func addressAlert(){
        let alert = UIAlertController(title: "Invalid Input", message: "Please enter a valid address.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
    }
    
    //Success Alert if data has been posted successfully
    func successAlert(){
        let alert = UIAlertController(title: "Success", message: "Line data sent successfully.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
    }
    
  
    
    // Function that gets called when return to home page button is pressed
     @objc func tappedReturn(){
        //pops current view off stack which brings user back to main page
        navigationController?.popViewController(animated: true)
        //Animates Transition
        dismiss(animated: true, completion: nil)
    }
    
    //Function that gets called when submit button is pressed
    
    @objc func tappedSubmit(){
        //Confirm addressForm is filled out
        if(addressForm==nil){
            //addressAlert()
            return
        }
        //Assign address to text from address Form
        guard let address = addressForm.text else {
            return
        }
        //get current date to send with form
        let date = Date()
        //format date with previously declared date/time formatters
        let currentDate = dateFormatter.string(from: date)
        // Retrieve time
        let currentTime = timeFormatter.string(from: date)
        //declare url user is posting to
        let url = URL(string: "https://ix.cs.uoregon.edu/~masonj/422lineform.php")
                  // Create a URLRequest variable and give it address url, method of POST
          var request : URLRequest = URLRequest(url: url!)
          request.httpMethod = "POST"
        
         //Create post data with address, minutes, date and time
         let postData = "l_addr=\(address)&l_wait=\(minutes)&l_date=\(currentDate)&l_time=\(currentTime)"
         print(postData)
         // Insert the data string into the request body data
         request.httpBody = postData.data(using: String.Encoding.utf8)
         // Start a session which transmits our data through a shared.dataTask()
         let dataTask = URLSession.shared.dataTask(with: request) { data,response,error in
             if let error = error {
                 print("Error occured \(error)")
                 return
             }
             else{
                //self.successAlert()
            }
             if let data = data, let _ = String(data: data, encoding: .utf8) {
                 //print(text)
             }
         }
         dataTask.resume()
        
        //Returns you to main screen
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
        
       }

}

    
  
