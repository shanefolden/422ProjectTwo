//
//  ViewController.swift
//  LocationBase
//
//  Created by Irfan Filipovic on 4/18/20.
//  Copyright © 2020 Irfan Filipovic. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    // This is how vars entered in Main.storyboard and LaunchScreen.storyboard are accessed
    // From the storyboard 'control' and click the object to this screen
    // A blue line should appear while dragging and when you drop creates var as below
    // Mark is how you declare what is happening
    //MARK: Properties
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    @IBOutlet weak var startHomeButton: UIButton!
    @IBOutlet weak var stopHomeButton: UIButton!
    
    @IBOutlet weak var trackingSpinner: UIActivityIndicatorView!
    
    // Create var locationManager to be accessed by all functions in class
    var locationManager: CLLocationManager?
    
    // Create dateFormatters for 4 cases described below
    let dateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    let minFormatter = DateFormatter()
    let secFormatter = DateFormatter()
    
    // Create variable to detect if app has been launched on this device before
    let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
    
    // creat variable to determine if user at home and data needs to be obfuscated
    var atHome = false

    // When view loads, create titles for buttons, when start is available say start, after pressed indicate tracking.
    // When pressed calls tappedStart same for stop and tappedStop
    
    // Initialize the locationManager, delegate self so that it receives the location updates not something else
    // Requests authorization for always, must include Keys in Info.plist for "Location Always" and "When in Use"
    // allowBackground and pauseLocation vals allow for location to be updated in the background without pause
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // check if App has been launched before.
        // If not, set lat offset to random number between .05 and .25 miles
        trackingSpinner.stopAnimating()
        if !launchedBefore{
            // Equivelant of .05-.25 mi in latitude
            var randomLat =  Double.random(in: 0.0007 ..< 0.0036)
            //  Multiplier is var to determine if lat offset is added or subtracted
            let multiplier = Bool.random()
            if multiplier {
                randomLat = randomLat * -1
            }
            // Adds latOffset to constant user values that way it doesnt change if the user quits the app
            UserDefaults.standard.set(randomLat, forKey: "latOffset")
        }
        // start/stop button setup
        startButton.setTitle("Start Button", for:.normal)
        startButton.setTitle("tracking...", for:.disabled)
        
        startButton.addTarget(self, action:#selector(self.tappedStart), for:.touchUpInside)
        
        stopButton.addTarget(self, action:#selector(self.tappedStop), for:.touchUpInside)
        
        //at home button setup
        startHomeButton.setTitle("At home?", for:.normal)
        startHomeButton.setTitle("Currently: home.", for:.disabled)
        
        stopHomeButton.setTitle("Not at home", for:.normal)
        stopHomeButton.setTitle("Currently: not home.", for:.disabled)
        
        startHomeButton.addTarget(self, action:#selector(self.tappedStartHome), for:.touchUpInside)
               
        stopHomeButton.addTarget(self, action:#selector(self.tappedStopHome), for:.touchUpInside)

        // Location Setup
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        locationManager!.allowsBackgroundLocationUpdates = true
        locationManager!.pausesLocationUpdatesAutomatically = false
        
        // Date Formatting
        dateFormatter.dateFormat = "yyyy-MM-dd"
        // Time Formatting
        timeFormatter.dateStyle = .none
        timeFormatter.dateFormat = "HH:mm:ss"
        
        // 5 Minute timer implementation Formatters
        // Retrieve minute value
        minFormatter.dateStyle = .none
        minFormatter.dateFormat = "mm"
        // Retrieve second value
        secFormatter.dateStyle = .none
        secFormatter.dateFormat = "ss"
    }
    
    // Button selector must indicate objective c, therefore declare function in objectiveC (Nice work Siqi)!!!!
    // Once tapped, disable start/enable stop, and startupdating location. Added same location vals to ensure that background runs, may be redundant
    // Spin if on, if off spinner doesnt show
    @objc func tappedStart(){
        startButton.isEnabled = false
        stopButton.isEnabled = true
        locationManager?.startUpdatingLocation()
        locationManager!.allowsBackgroundLocationUpdates = true
        locationManager!.pausesLocationUpdatesAutomatically = false
        trackingSpinner.startAnimating()
    }
    // If stop is tapped, disable stop, enable start, and stop updatingLocation
    @objc func tappedStop(){
        startButton.isEnabled = true
        stopButton.isEnabled = false
        locationManager?.stopUpdatingLocation()
        trackingSpinner.stopAnimating()
    }
    
    @objc func tappedStartHome(){
        startHomeButton.isEnabled = false
        stopHomeButton.isEnabled = true
        atHome = true
    }
       // If stop is tapped, disable stop, enable start, and stop updatingLocation
    @objc func tappedStopHome(){
       startHomeButton.isEnabled = true
       stopHomeButton.isEnabled = false
       atHome = false
   }

    // Every second the location is updated this function is called by LocationManager
    // locations stores the locations retrieved, and the most recent addition (index 0) is the current location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Create var location of type CLLocation, store current location in location
        var location: CLLocation
        location = locations[0]

        // POST Setup
        // Create URLString to db upload page
        let url = URL(string: "https://ix.cs.uoregon.edu/~masonj/422backend.php")

        // Create a URLRequest variable and give it address url, method of POST as it send data in body
        var request : URLRequest = URLRequest(url: url!)
        request.httpMethod = "POST"
        // Create formatted vars of 4 decimal places, round value after multiplying by 10000 and then divide by 10000, will find source and post.
        var locationLat = Double(round(10000*location.coordinate.latitude)/10000)
        let locationLong = Double(round(10000*location.coordinate.longitude)/10000)
       
        // If user pressed at home button
        if(atHome) {
            // get Stored lat offset val and add it to the current location latitude
            let latAdder = UserDefaults.standard.double(forKey: "latOffset")
            locationLat += latAdder
            locationLat = Double(round(10000*locationLat)/10000)
        }
        
        // Retrieve date
        let date = dateFormatter.string(from: location.timestamp)
        // Retrieve time
        let time = timeFormatter.string(from: location.timestamp)
        // Get minutes and seconds
        let minCheck = Int(minFormatter.string(from: location.timestamp))
        let secCheck = Int(secFormatter.string(from: location.timestamp))
        
        // If minutes is a mod of 5, and seconds is 0 then conduct post of data, ensures data is posted every 5 minutes
        if((minCheck! % 5 == 0) && (secCheck! == 00)) {
            
            // Create string that contains UIDevice ID which is unique for each device, and insert vars generated above
            let postData = "userId=\(UIDevice.current.identifierForVendor?.uuidString ?? "001")&tDate=\(date)&tTime=\(time)&tLatitude=\(locationLat)&tLongitude=\(locationLong)"
            
            // To test code without posting data to db that is down comment from here
            
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
            // End block comment here to test without posting
            
            // print rather than post for testing purposes, remove if posting to db
            //print(postData)

        } else { // If not 5 min and 0 sec then do this
            //print("working")
        }
        }
        
        // This function called when authorization status changes, so when we prompt
        // Switching on status indicates we can do certain tasks depending on the authorization
        
    
        // Maybe implement popup if not allowed to say its required
    
        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            switch(status) {
            case .restricted, .denied:
                print("Location not allowed")
            case .authorizedAlways:
                print("authed always")
            case .authorizedWhenInUse:
                print("authed when in use")
            case .notDetermined:
                print("nothing to do")
            @unknown default:
                print("default")
            }
    }
}


