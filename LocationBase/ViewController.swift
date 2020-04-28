//
//  ViewController.swift
//  LocationBase
//
//  Created by Irfan Filipovic on 4/18/20.
//  Modified by Irfan Filipovic, Shane Folden, Siqi Wang

//  Last modified by: SF
//  Last modified on: 04/26/20

//  Following code operates tracking location and posting to the database.
//  Implements button functionality and timed updates, can be changed to update at any interval

import UIKit
import CoreLocation
import UserNotifications

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    //  Class creates:
    //    1. A spinner and button variables connected to placed objects on Main.storyboard
    //MARK: Properties
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var startHomeButton: UIButton!
    @IBOutlet weak var stopHomeButton: UIButton!
    @IBOutlet weak var trackingSpinner: UIActivityIndicatorView!
    //    2. A Location Manager which uses Apple's standard location services
    var locationManager: CLLocationManager?
    //    3. Two formatters for posting data into the database, date and time.
    let dateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    //    4. Two formatters for checking post time, minutes and seconds
    let minFormatter = DateFormatter()
    let secFormatter = DateFormatter()
    //    5. Variable to detect if app has been launched on this device before
    let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
    //    6. Variable to determine if user at home and data needs to be obfuscated
    var atHome = false

    //    7. Implement own functions on view load
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor=UIColor.init(red: 199/255, green: 213/255, blue: 159/255, alpha: 1)
        // Ensure spinner disabled
        trackingSpinner.stopAnimating()
        // Check if app has been launched before.
        // If not, set lat offset vraiable to random number between .05 and .25 miles
        if !launchedBefore{
            // Equivalant of .05-.25 mi in latitude
            var randomLat =  Double.random(in: 0.0007 ..< 0.0036)
            //  Multiplier is var to determine if lat offset is added or subtracted
            let multiplier = Bool.random()
            if multiplier {
                randomLat = randomLat * -1
            }
            // Adds latOffset to constant user values that way it doesnt change if the user quits the app
            UserDefaults.standard.set(randomLat, forKey: "latOffset")
        }
        // Start button title switches on status.
        // Call to objective c func tappedStart on touch.
        startButton.setTitle("Start Button", for:.normal)
        startButton.setTitle("tracking...", for:.disabled)
        startButton.addTarget(self, action:#selector(self.tappedStart), for:.touchUpInside)
        // Call to objective c func tappedStart on touch.
        stopButton.addTarget(self, action:#selector(self.tappedStop), for:.touchUpInside)
        // At home button title switches on status.
        // Call to objective c func tappedStartHome on touch.
        startHomeButton.setTitle("At home?", for:.normal)
        startHomeButton.setTitle("Currently: home.", for:.disabled)
        startHomeButton.addTarget(self, action:#selector(self.tappedStartHome), for:.touchUpInside)
        // Not at home button title switches on status.
        // Call to objective c func tappedStopHome on touch.
        stopHomeButton.setTitle("Not at home", for:.normal)
        stopHomeButton.setTitle("Currently: not home.", for:.disabled)
        stopHomeButton.addTarget(self, action:#selector(self.tappedStopHome), for:.touchUpInside)

        
        // Add border for buttons
        startHomeButton.layer.borderWidth = 1
        startHomeButton.layer.borderColor = UIColor.black.cgColor
        startHomeButton.layer.cornerRadius = 5
        
        stopHomeButton.layer.borderWidth = 1
        stopHomeButton.layer.borderColor = UIColor.black.cgColor
        stopHomeButton.layer.cornerRadius = 5

        startButton.layer.borderWidth = 1
        startButton.layer.borderColor = UIColor.black.cgColor
        startButton.layer.cornerRadius = 5
        
        stopButton.layer.borderWidth = 1
        stopButton.layer.borderColor = UIColor.black.cgColor
        stopButton.layer.cornerRadius = 5
        
        // Add background color for buttons, add color of text
        // Start buttons are blue, stop buttons are red
        startButton.backgroundColor = UIColor(red: 0/255, green: 123/255, blue: 255/255, alpha: 1)
        startButton.setTitleColor(.white, for: .normal)
        
        stopButton.backgroundColor = UIColor(red: 255/255, green: 82/255, blue: 82/255, alpha: 1)
        stopButton.setTitleColor(.white, for: .normal)
        
        startHomeButton.backgroundColor = UIColor(red: 0/255, green: 123/255, blue: 255/255, alpha: 1)
        startHomeButton.setTitleColor(.white, for: .normal)
        
        stopHomeButton.backgroundColor = UIColor(red: 255/255, green: 82/255, blue: 82/255, alpha: 1)
        stopHomeButton.setTitleColor(.white, for: .normal)
        
        // Disable Stop button and not at home button
        // Since this is the default state they cannot be pressed until
        // the user pressed the start button or the at home button
        // The alpha value changes the brightness of the background color
        stopButton.isEnabled = false
        stopButton.alpha = 0.5
        stopHomeButton.isEnabled = false
        stopHomeButton.alpha = 0.5
        

        // Location Manager initialization, delegates calls to self
        // Requests authorization, response on change sent to func with didChangeAuthorization
        // Persists tracking when app is in the background
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
    
    // Button selector must indicate objective c, therefore override
    // Once tapped, disable start | enable stop | enable spinner, and start updating location.
    // Added same location vals to ensure that background runs, may be redundant but no error.
    @objc func tappedStart(){
        startButton.isEnabled = false
        startButton.alpha  = 0.5;
        stopButton.isEnabled = true
        stopButton.alpha  = 1.0;
        locationManager?.startUpdatingLocation()
        locationManager!.allowsBackgroundLocationUpdates = true
        locationManager!.pausesLocationUpdatesAutomatically = false
        trackingSpinner.startAnimating()
    }
    // If stop is tapped, disable stop | enable start | stop spinner, and stop updating location.
    @objc func tappedStop(){
        startButton.isEnabled = true
        startButton.alpha  = 1.0;
        stopButton.isEnabled = false
        stopButton.alpha  = 0.5;
        locationManager?.stopUpdatingLocation()
        trackingSpinner.stopAnimating()
    }
    // If start is tapped, disable start | enable stop, and set atHome true.
    @objc func tappedStartHome(){
        startHomeButton.isEnabled = false
        startHomeButton.alpha = 0.5
        stopHomeButton.alpha = 1.0
        stopHomeButton.isEnabled = true
        atHome = true
    }
    // If stop is tapped, disable stop | enable start, and set atHome false.
    @objc func tappedStopHome(){
        startHomeButton.isEnabled = true
        stopHomeButton.isEnabled = false
        stopHomeButton.alpha = 0.5
        startHomeButton.alpha = 1.0
        atHome = false
   }

    // locations stores the locations retrieved, and the most recent addition (index 0) is the current location
    // location updates about every second
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Create var location of type CLLocation, store current location in location
        var location: CLLocation
        location = locations[0]
        // Get minutes and seconds
        let minCheck = Int(minFormatter.string(from: location.timestamp))
        let secCheck = Int(secFormatter.string(from: location.timestamp))
        // If the minutes is a multiple of 5 and it is the first second of that minute
        // Post data, else do nothing
        if((minCheck! % 5 == 0) && (secCheck! == 00)) {
            // POST Setup
            // Create URLString to database upload page
            let url = URL(string: "https://ix.cs.uoregon.edu/~masonj/422backend.php")
            // Create a URLRequest variable and give it address url, method of POST
            var request : URLRequest = URLRequest(url: url!)
            request.httpMethod = "POST"
            // Create formatted vars of 4 decimal places, round value after multiplying by 10000 and then divide by 10000.
            // Shift the number 4 indices left, round the number to replace trailing decimals
            // Shift back 4 indices right for original value with 4 decimals
            var locationLat = Double(round(10000*location.coordinate.latitude)/10000)
            let locationLong = Double(round(10000*location.coordinate.longitude)/10000)
            // If user pressed at home button
            if(atHome) {
                // Get stored lat offset val and add it to the current location latitude
                let latAdder = UserDefaults.standard.double(forKey: "latOffset")
                locationLat += latAdder
                locationLat = Double(round(10000*locationLat)/10000)
            }
            // Retrieve date
            let date = dateFormatter.string(from: location.timestamp)
            // Retrieve time
            let time = timeFormatter.string(from: location.timestamp)
            // Create string that contains UIDevice ID which is unique for each device, and insert vars generated above
            let postData = "userId=\(UIDevice.current.identifierForVendor?.uuidString ?? "001")&tDate=\(date)&tTime=\(time)&tLatitude=\(locationLat)&tLongitude=\(locationLong)"
            // Insert the data string into the request body data
            request.httpBody = postData.data(using: String.Encoding.utf8)
            // Start a session which transmits our data through a shared.dataTask()
            let dataTask = URLSession.shared.dataTask(with: request) { data,response,error in
                if let error = error {
                    print("Error occured \(error)")
                    return
                }
                if let data = data, let _ = String(data: data, encoding: .utf8) {
                    //print("Reponse data string:\n\(_)")
                }
            }
            dataTask.resume()
        }
    }
/* *** for testing purposes and furthur implementation *** */
/*
        // This function called when authorization status changes, so when we prompt
        // Switching on status indicates we can do certain tasks depending on the authorization
        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            switch(status) {
            case .restricted, .denied:
                //print("Location not allowed")
            case .authorizedAlways:
                //print("authed always")
            case .authorizedWhenInUse:
                //print("authed when in use")
            case .notDetermined:
                //print("nothing to do")
            @unknown default:
                //print("default")
            }
*/
    }
