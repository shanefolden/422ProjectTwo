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
    @IBOutlet weak var latitudeVal: UITextField!
    @IBOutlet weak var longitudeVal: UITextField!
    
    var main:ViewController?
    
    let dateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    override func viewDidLoad() {
        super.viewDidLoad()
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
        let interval = timeInterval.text
        UserDefaults.standard.set(interval, forKey: "frequency")
    }
    @objc func goHome() {
        //pops current view off stack which brings user back to main page
        navigationController?.popViewController(animated: true)
        navigationController?.popViewController(animated: true)
        //Animates Transition
        dismiss(animated: true, completion: nil)
    }
    
    @objc func sendLocation() {
        // POST Setup
        // Create URLString to database upload page
        let url = URL(string: "https://ix.cs.uoregon.edu/~masonj/422backend.php")
        // Create a URLRequest variable and give it address url, method of POST
        var request : URLRequest = URLRequest(url: url!)
         request.httpMethod = "POST"
        let locationLat = Float(latitudeVal.text ?? "37.0000")
        let locationLong = Float(longitudeVal.text ?? "122.0000")

        let date = Date()
        let currentDate = dateFormatter.string(from: date)

        // Retrieve time
        let currentTime = timeFormatter.string(from: date)

        // Create string that contains UIDevice ID which is unique for each device, and insert vars generated above
        let postData = "userId=\(UIDevice.current.identifierForVendor?.uuidString ?? "001")&tDate=\(currentDate)&tTime=\(currentTime)&tLatitude=\(locationLat ?? 37.0000)&tLongitude=\(locationLong ?? 122.0000)&tTimeAtLocation=\(0)"
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
}

