//
//  ViewController.swift
//  LocationBase
//
//  Created by Irfan Filipovic on 4/18/20.
//  Copyright © 2020 Irfan Filipovic. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    var locationManager: CLLocationManager?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Location Setup
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        locationManager?.startUpdatingLocation()
        

    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var location: CLLocation
        location = locations[0]
        

        // POST Setup
        let url = URL(string: "https://ix.cs.uoregon.edu/~masonj/422backend.php")

        var request : URLRequest = URLRequest(url: url!)
        request.httpMethod = "POST"
        // Create formatted vars
        let locationLat = Double(round(10000*location.coordinate.latitude)/10000)
        let locationLong = Double(round(10000*location.coordinate.longitude)/10000)
        
        // Date Formatting
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeStyle = .none
        let date = dateFormatter.string(from: location.timestamp)
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .none
        timeFormatter.dateFormat = "HH:mm:ss"
        let time = timeFormatter.string(from: location.timestamp)
        
        let postData = "userId=\(UIDevice.current.identifierForVendor?.uuidString ?? "001")&tDate=\("2020-04-19")&tTime=\(time)&tLatitude=\(locationLat)&tLongitude=\(locationLong)&tTAL=11"
        
        request.httpBody = postData.data(using: String.Encoding.utf8)
        
        let dataTask = URLSession.shared.dataTask(with: request) { data,response,error in
            if let error = error {
                print("Error occured \(error)")
                return
            }
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print("Reponse data string:\n\(dataString)")
            }
        }
        dataTask.resume()
        }
        
        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            switch(status) {
            case .restricted, .denied:
                print("Location not allowed")
            case .authorizedAlways, .authorizedWhenInUse:
                print("authed")
            case .notDetermined:
                print("nothing to do")
            @unknown default:
                print("default")
            }
    }
}


