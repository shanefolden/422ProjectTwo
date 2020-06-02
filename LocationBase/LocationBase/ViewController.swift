//
//  ViewController.swift
//  LocationBase
//
//  Created by Irfan Filipovic on 4/18/20.
//  Modified by Irfan Filipovic, Shane Folden, Siqi Wang

//  Last modified by: SF
//  Last modified on: 05/28/20

//  Following code operates tracking location and posting to the database.
//  Implements button functionality and timed updates, can be changed to update at any interval

import UIKit
import CoreLocation
import UserNotifications

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    //  Class creates:
    //    1. A spinner and button variables connected to placed objects on Main.storyboard
    //MARK: Properties

    @IBOutlet weak var dataCollectionSwitch: UISwitch!
    @IBOutlet weak var atHomeSwitch: UISwitch!
    
    @IBOutlet weak var trackingGif: UIImageView!
    
    @IBOutlet weak var trackLabel: UILabel!
    
    @IBOutlet weak var lineButton: UIButton!
    
    
    @IBOutlet weak var devButton: UIButton!
    
    var errorVal = ""
    var testVal = "<!-- NEW COMMENT YO -->"
  
  
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
    //    7. Variable to determine if first ping should be sent and if after first 'second', i.e on start
    var firstPing = false
    var secondPing = false
    //    8. Variables for previous long. and lat. and minute
    var prevLong = 0.0
    var prevLat = 0.0
    var prevMin = 0
    //    9. time at location variable and range for location (.025 miles)
    var timeAtLocation = 0
    var sameLocationCheck = 0.00035
    

    //    10. Implement own functions on view load
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor=UIColor.init(red: 199/255, green: 213/255, blue: 159/255, alpha: 1)
        
        // Initalize method for data collection switch to call
        dataCollectionSwitch.addTarget(self, action: #selector(stateChanged), for: .valueChanged)
        atHomeSwitch.addTarget(self, action: #selector(homeChanged), for: .valueChanged)
        lineButton.layer.borderWidth = 1
        lineButton.layer.borderColor = UIColor.black.cgColor
        lineButton.layer.cornerRadius = 5
        lineButton.backgroundColor = UIColor.white
        lineButton.setTitleColor(.black, for: .normal)
        
        devButton.layer.borderWidth = 1
             devButton.layer.borderColor = UIColor.black.cgColor
             devButton.layer.cornerRadius = 5
        devButton.backgroundColor = UIColor.white
        devButton.setTitleColor(.black, for: .normal)
        
             
        
  
        
     
        trackingGif.loadGif(name: "currentlyTracking")
        trackingGif.isHidden = true
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
            UserDefaults.standard.set(5, forKey: "frequency")
            // Set switches to off state
            dataCollectionSwitch.setOn(false, animated:false)
            atHomeSwitch.setOn(false, animated:false)
        }
    
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
  
    // If stop is tapped, disable stop | enable start | stop spinner, and stop updating location.
 
    // If start is tapped, disable start | enable stop, and set atHome true.

    
    @objc func stateChanged(dataCollectionSwitch: UISwitch) {
        if dataCollectionSwitch.isOn {
        
            firstPing = true
            locationManager?.startUpdatingLocation()
            locationManager!.allowsBackgroundLocationUpdates = true
            locationManager!.pausesLocationUpdatesAutomatically = false
            trackingGif.isHidden = false
            
        }
        else {
             locationManager?.stopUpdatingLocation()
          timeAtLocation = 0
           prevLat = 0.0
           prevLong = 0.0
           prevMin = 0
            trackingGif.isHidden = true
            
    
        }
    }
    
    @objc func homeChanged(atHomeSwitch: UISwitch) {
           if atHomeSwitch.isOn {
                atHome = true
                print(atHome)
               
           }
           else {
                atHome = false
            print(atHome)
           }
       }
    
    // locations stores the locations retrieved, and the most recent addition (index 0) is the current location
    // location updates about every second
    func locationManager(_ manager: CLLocationManager, didUpdateLocations
        locations: [CLLocation]) {
        // Create var location of type CLLocation, store current location in location
        var location: CLLocation
        location = locations[0]
        // Get minutes and seconds
        let minCheck = Int(minFormatter.string(from: location.timestamp))
        let secCheck = Int(secFormatter.string(from: location.timestamp))
        let timeInterval = UserDefaults.standard.integer(forKey: "frequency")
        // If the minutes is a multiple of 5 and it is the first second of that minute
        // Post data, else do nothing
        if(((minCheck! % timeInterval == 0) && (secCheck! == 00)) || firstPing) {
            print(firstPing)
            print(secondPing)
            print(prevMin)
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
            print(locationLat)
            print(locationLong)
            if(atHome) {
                // Get stored lat offset val and add it to the current location latitude
                let latAdder = UserDefaults.standard.double(forKey: "latOffset")
                locationLat += latAdder
                locationLat = Double(round(10000*locationLat)/10000)
            }
            // Check curr location if same as last or within 0.025 miles
            if(abs(locationLong - prevLong)<=sameLocationCheck && abs(locationLat - prevLat)<=sameLocationCheck) {
                // If after first ping, calculate distance from start time
                // else add 5 minutes
                if(secondPing) {
                    print(prevMin)
                    timeAtLocation += (timeInterval - (prevMin % 5))
                    secondPing = false
                } else {
                    timeAtLocation += timeInterval
                }
            } else {
                // If firstPing set secondPing and minute, else set time to 0
                if(firstPing == false) {
                    timeAtLocation = 0
                } else {
                    secondPing = true
                    prevMin = minCheck!
                }
            }
            // Not first ping
            firstPing = false
            print(firstPing)
            print(secondPing)
            print(prevMin)
            // Set curr values as previous
            prevLong = locationLong
            prevLat = locationLat
            // Retrieve date
            let date = dateFormatter.string(from: location.timestamp)
            // Retrieve time
            let time = timeFormatter.string(from: location.timestamp)
            // Create string that contains UIDevice ID which is unique for each device, and insert vars generated above
            let postData = "userId=\(UIDevice.current.identifierForVendor?.uuidString ?? "001")&tDate=\(date)&tTime=\(time)&tLatitude=\(locationLat)&tLongitude=\(locationLong)&tTimeAtLocation=\(timeAtLocation)"
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
                    let string = e.prefix(23)
                    if(String(string) != self.testVal) {
                        self.errorVal = "Error Sending Data!"
                    } else {
                        self.errorVal = "Success"
                    }
                }
            }
            dataTask.resume()
            while(errorVal == "") {
                //wait
            }
            if(errorVal != "Success") {
                let alert = UIAlertController(title: "Response", message: errorVal, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                NSLog("The \"OK\" alert occured.")
                }))
                self.present(alert, animated: true, completion: nil)
            }
            errorVal = ""
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
