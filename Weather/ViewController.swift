//
//  ViewController.swift
//  Weather
//
//  Created by Juhi Bhavsar on 2022-07-26.
//

import UIKit
import CoreLocation

class ViewController: UIViewController,UITextFieldDelegate
                       {

    @IBOutlet weak var Searchtextfield: UITextField!
    
    @IBOutlet weak var Imageweather: UIImageView!
    
    @IBOutlet weak var Tempcheck: UILabel!
    
    @IBOutlet weak var Weathercondition: UILabel!
    
    @IBOutlet weak var Locationlabel: UILabel!
    private let locationManager = CLLocationManager()
    private let locationManagerDelegate = MyLocationManagerDelegate()
   override func viewDidLoad() {
        super.viewDidLoad()
     
       locationManager.delegate = locationManagerDelegate
      


        displayWeatherImage()
        Searchtextfield.delegate = self
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.endEditing(true)
        return true
    }


    private func displayWeatherImage(){
        let config = UIImage.SymbolConfiguration(paletteColors:[UIColor.systemYellow])
        Imageweather.preferredSymbolConfiguration = config
      //  Imageweather.image = UIImage(systemName: "sun.max")
        
    }
    
    @IBAction func Onlocationtapped(_ sender: UIButton) {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
      
    }
    private func displayLocation(LocationText : String){
        Locationlabel.text = LocationText
    }
  class MyLocationManagerDelegate : NSObject,CLLocationManagerDelegate {
      func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
          print("Got Location")
          if let location = locations.last {
              
          }
          
      }
      func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
          print(error)
         
      
         
      }
         
          
      
    }

    @IBAction func OnSearch(_ sender: UIButton) {
        loadWeather(search : Searchtextfield.text)
    }
    private func loadWeather(search: String?){
        guard let search = search else {
           
            return
        }
        guard let url = getURL(query: search)else{
                print("Could not get")
                return
        }
        let session = URLSession.shared
        let dataTask = session.dataTask(with: url) { data,response,error  in
          print("Network call")
            guard error == nil else {
                print("Received error")
                return
            }
            guard let data = data else{
                print("No data recieved")
                return
            }
            if let weatherResponse =  self.parseJson(data: data){
                print(weatherResponse.location.name)
                print(weatherResponse.current.temp_c)
                
            
                DispatchQueue.main.async {
                    self.Locationlabel.text = weatherResponse.location.name
                    self.Tempcheck.text = "\(weatherResponse.current.temp_c)C"
                    self.Weathercondition.text = weatherResponse.current.condition.text
                    if weatherResponse.current.condition.code == 1000{
                        self.Imageweather.image = UIImage(systemName: "sun.max")

                    }
                    else if(weatherResponse.current.condition.code == 1003)
                    {
                        let config = UIImage.SymbolConfiguration(paletteColors: [.systemBlue, .systemYellow])
                        self.Imageweather.preferredSymbolConfiguration = config
                        self.Imageweather.image = UIImage(systemName: "cloud.sun")
                            
                    }
                    
                    else if(weatherResponse.current.condition.code == 1030)
                    {
                        let config = UIImage.SymbolConfiguration(paletteColors: [.systemBlue, .systemGray])
                        self.Imageweather.preferredSymbolConfiguration = config
                        self.Imageweather.image = UIImage(systemName: "cloud.fog")
                    }
                    else if (weatherResponse.current.condition.code == 1006)
                    {
                        let config = UIImage.SymbolConfiguration(paletteColors: [.systemBlue, .systemFill])
                        self.Imageweather.preferredSymbolConfiguration = config
                        self.Imageweather.image = UIImage(systemName: "cloud.fill")
                    }
                    else if (weatherResponse.current.condition.code == 1009)
                    {
                        let config = UIImage.SymbolConfiguration(paletteColors: [.systemBlue, .systemYellow])
                        self.Imageweather.preferredSymbolConfiguration = config
                        self.Imageweather.image = UIImage(systemName: "cloud.sun")
                    } else if (weatherResponse.current.condition.code == 1135)
                    {
                        let config = UIImage.SymbolConfiguration(paletteColors: [.systemBlue, .systemGray, .systemFill])
                        self.Imageweather.preferredSymbolConfiguration = config
                        self.Imageweather.image = UIImage(systemName: "cloud.fog.fill")
                    }
                    else if (weatherResponse.current.condition.code == 1153)
                    {
                        let config = UIImage.SymbolConfiguration(paletteColors: [.systemBlue, .systemIndigo])
                        self.Imageweather.preferredSymbolConfiguration = config
                        self.Imageweather.image = UIImage(systemName: "cloud.drizzle")
                    }
                    else if (weatherResponse.current.condition.code == 1183)
                    {
                        let config = UIImage.SymbolConfiguration(paletteColors: [.systemBlue, .systemPink , .systemGray])
                        self.Imageweather.preferredSymbolConfiguration = config
                        self.Imageweather.image = UIImage(systemName: "cloud.rain.fill")
                    }
                    else if (weatherResponse.current.condition.code == 1213)
                    {
                        let config = UIImage.SymbolConfiguration(paletteColors: [.systemBlue,.systemGray4 , .systemGray])
                        self.Imageweather.preferredSymbolConfiguration = config
                        self.Imageweather.image = UIImage(systemName: "cloud.snow.fill")
                    }
                    else if (weatherResponse.current.condition.code == 1273)
                    {
                        let config = UIImage.SymbolConfiguration(paletteColors: [.systemBlue, .systemRed , .systemPink, .systemGray])
                        self.Imageweather.preferredSymbolConfiguration = config
                        self.Imageweather.image = UIImage(systemName: "cloud.bolt.rain.fill")
                    }
                    else
                    {
                        return
                    }
                    
                    
                }
                
            }
            
           
        }
        dataTask.resume()
    }
    
    private func getURL(query: String) -> URL? {
        let baseurl = "https://api.weatherapi.com/v1"
        let currentendpoint = "/current.json"
        let apikey = "c2190268cc8e4b209eb22348222807"
       
        guard let url =  "\(baseurl)\(currentendpoint)?key=\(apikey)&q=\(query)"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        print(url)
        return URL(string: url)
            
        }
    
    private func parseJson(data: Data) -> WeatherResponse?
    {
        let decoder = JSONDecoder()
        var weather: WeatherResponse?
        do{
            weather = try decoder.decode(WeatherResponse.self,from:data)
        }catch{
            print("Error Decoding")
        }
        return weather
    
    }
    
}
struct WeatherResponse: Decodable {
    let location: Location
    let current: Weather
}
struct Location: Decodable {
    let name:String
}
struct Weather: Decodable{
    let temp_c:Float
    let condition: WeatherCondition
}
struct WeatherCondition: Decodable{
    let text:String
    let code:Int
}

/*
{
    "location": {
        "name": "London",
        "region": "City of London, Greater London",
        "country": "United Kingdom",
        "lat": 51.52,
        "lon": -0.11,
        "tz_id": "Europe/London",
        "localtime_epoch": 1659042788,
        "localtime": "2022-07-28 22:13"
    },
    "current": {
        "last_updated_epoch": 1659042000,
        "last_updated": "2022-07-28 22:00",
        "temp_c": 19.0,
        "temp_f": 66.2,
        "is_day": 0,
        "condition": {
            "text": "Clear",
            "icon": "//cdn.weatherapi.com/weather/64x64/night/113.png",
            "code": 1000
        },
        "wind_mph": 11.9,
        "wind_kph": 19.1,
        "wind_degree": 100,
        "wind_dir": "E",
        "pressure_mb": 1018.0,
        "pressure_in": 30.06,
        "precip_mm": 0.0,
        "precip_in": 0.0,
        "humidity": 56,
        "cloud": 0,
        "feelslike_c": 19.0,
        "feelslike_f": 66.2,
        "vis_km": 10.0,
        "vis_miles": 6.0,
        "uv": 1.0,
        "gust_mph": 11.6,
        "gust_kph": 18.7
    }
}
 

     */
