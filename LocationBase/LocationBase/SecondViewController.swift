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

class SecondViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, MKLocalSearchCompleterDelegate  {
     let pickerData = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60]
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var addressForm: UITextField!
    
    @IBOutlet weak var picker: UIPickerView!
    
    @Published var coordinates = CLLocationCoordinate2D()
    
   
    
    @IBOutlet weak var searchResultsTableView: UITableView!
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    let dateFormatter = DateFormatter()
     let timeFormatter = DateFormatter()
    var minutes = -1
    
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchCompleter.delegate = self
        dateFormatter.dateFormat = "yyyy-MM-dd"
        // Time Formatting
        timeFormatter.dateStyle = .none
        timeFormatter.dateFormat = "HH:mm:ss"
        
        submitButton.addTarget(self, action:#selector(self.tappedSubmit), for:.touchUpInside)
        
        self.picker.delegate = self
        self.picker.dataSource = self
       

        // Do any additional setup after loading the view.
    }
    
   
   
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        minutes = Int(pickerData[row])
        return String(pickerData[row])
    }
    
    func addressAlert(){
        let alert = UIAlertController(title: "Invalid Input", message: "Please enter a valid address.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
    }
    
    func successAlert(){
        let alert = UIAlertController(title: "Success", message: "Line data sent successfully.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
    }
    
  func getCoordinate( addressString : String,
            completionHandler: @escaping(CLLocationCoordinate2D, NSError?) -> Void ) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(addressString) { (placemarks, error) in
            if error == nil {
                if let placemark = placemarks?[0] {
                    let location = placemark.location!
                    completionHandler(location.coordinate, nil)
                    
                    return
                }
            }
                
            completionHandler(kCLLocationCoordinate2DInvalid, error as NSError?)
        }
    }

    
    @objc func tappedSubmit(){
        if(addressForm==nil){
            //addressAlert()
            return
        }
        guard let address = addressForm.text else {
            return
        }
        if (address.count==0){
            //addressAlert()
            return
        }
        
        
        let date = Date()
       let currentDate = dateFormatter.string(from: date)
       // Retrieve time
       let currentTime = timeFormatter.string(from: date)
        print(currentDate)
        print(currentTime)
        print(address)
        print(minutes)
//         getCoordinate(addressString: address) { (responseCoordinate, error) in
//                    if error == nil {
//                       self.coordinates = responseCoordinate
//                        let latitude = self.coordinates.latitude
//                        let longitude = self.coordinates.longitude
//
//                  }
//               }
       
        
        let url = URL(string: "https://ix.cs.uoregon.edu/~masonj/422lineform.php")
                  // Create a URLRequest variable and give it address url, method of POST
          var request : URLRequest = URLRequest(url: url!)
          request.httpMethod = "POST"
        
         // Create string that contains UIDevice ID which is unique for each device, and insert vars generated above
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
                print("fine")
            }
             if let data = data, let text = String(data: data, encoding: .utf8) {
                 print(text)
             }
         }
         dataTask.resume()
        
       }

}

    
  
