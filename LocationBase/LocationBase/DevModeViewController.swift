//
//  DevModeViewController.swift
//  LocationBase
//
//  Created by Shane Folden on 6/1/20.
//  Copyright © 2020 Irfan Filipovic. All rights reserved.
//

import UIKit
import CoreLocation

class DevModeViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var timeInterval: UITextField!
    @IBOutlet weak var sendCurrent: UIButton!
    @IBOutlet weak var submitInterval: UIButton!
    @IBOutlet weak var mainView: UIButton!
    
    var locationManager: CLLocationManager?
    let dateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        
        // Date Formatting
        dateFormatter.dateFormat = "yyyy-MM-dd"
        // Time Formatting
        timeFormatter.dateStyle = .none
        timeFormatter.dateFormat = "HH:mm:ss"
        
        sendCurrent.addTarget(self, action:#selector(self.sendLocation), for:.touchUpInside)
        
        submitInterval.addTarget(self, action:#selector(self.submitTime), for:.touchUpInside)
        
        mainView.addTarget(self, action:#selector(self.goHome), for:.touchUpInside)
    }
    @objc func submitTime() {
        //print(int(timeInterval.text))
       }
    @objc func sendLocation() {
        locationManager?.requestLocation()
       }
    
    @objc func goHome() {
        //pops current view off stack which brings user back to main page
        navigationController?.popViewController(animated: true)
        navigationController?.popViewController(animated: true)
        //Animates Transition
        dismiss(animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations
         locations: [CLLocation]) {
         // Create var location of type CLLocation, store current location in location
         var location: CLLocation
         location = locations[0]
         // POST Setup
         // Create URLString to database upload page
         let url = URL(string: "https://ix.cs.uoregon.edu/~masonj/422backend.php")
         // Create a URLRequest variable and give it address url, method of POST
         var request : URLRequest = URLRequest(url: url!)
         request.httpMethod = "POST"
         // Create formatted vars of 4 decimal places, round value after multiplying by 10000 and then divide by 10000.
         // Shift the number 4 indices left, round the number to replace trailing decimals
         // Shift back 4 indices right for original value with 4 decimals
         let locationLat = Double(round(10000*location.coordinate.latitude)/10000)
         let locationLong = Double(round(10000*location.coordinate.longitude)/10000)
         // If user pressed at home button
         print(locationLat)
         print(locationLong)
         // Retrieve date
         let date = dateFormatter.string(from: location.timestamp)
         // Retrieve time
         let time = timeFormatter.string(from: location.timestamp)
         // Create string that contains UIDevice ID which is unique for each device, and insert vars generated above
         let postData = "userId=\(UIDevice.current.identifierForVendor?.uuidString ?? "001")&tDate=\(date)&tTime=\(time)&tLatitude=\(locationLat)&tLongitude=\(locationLong)&tTimeAtLocation=\(0)"
         print(postData)
         // Insert the data string into the request body data
             request.httpBody = postData.data(using: String.Encoding.utf8)
             // Start a session which transmits our data through a shared.dataTask()
             let dataTask = URLSession.shared.dataTask(with: request) { data,response,error in
                 if let error = error {
                     print("Error occured \(error)")
                     return
                 }
                 if let data = data, let e = String(data: data, encoding: .utf8) {
                     print("Reponse data string:\n\(e)")
                 }
             }
             dataTask.resume()
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

