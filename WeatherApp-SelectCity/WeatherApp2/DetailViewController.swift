//
//  DetailViewController.swift
//  WeatherApp2
//
//  Created by Ania Wójcik on 15/06/2020.
//  Copyright © 2020 Ania Wójcik. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    var cities: Cities = Cities()
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var city: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var weatherType: UILabel!
    @IBOutlet weak var maxTemperature: UILabel!
    @IBOutlet weak var minTemperature: UILabel!
    @IBOutlet weak var wind: UILabel!
    @IBOutlet weak var humidity: UILabel!
    @IBOutlet weak var rain: UILabel!
    @IBOutlet weak var pressure: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var weatherPictogram: UIImageView!
    @IBOutlet weak var previousButton: UIButton!
    
    var currentDay: Int = 0
    var weatherData : [Daily] = []
    var name: String = ""



    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            self.navigationItem.title = detail.description
            self.name = detail.description
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let gradientView = GradientView(frame: self.view.bounds)
        self.view.insertSubview(gradientView, at: 0)
        configureView()
        self.previousButton.isEnabled = false
        self.previousButton.alpha = 0.3
    }

    var detailItem: NSString? {
        didSet {
            let index = cities.city.firstIndex(where: {($0.cityName == detailItem! as String)})!
            let lat = cities.city[index].lat
            let lon = cities.city[index].lon
            getWeatherData(cityName: self.description, lat: lat, lon: lon)
            configureView()
                }
            }
  
    @IBAction func previuosButtonOnClicked(_ sender: Any) {
      if(self.currentDay > 0) {
          self.currentDay -= 1
          self.nextButton.isEnabled = true
          self.nextButton.alpha = 1
      } else {
          self.previousButton.isEnabled = false
          self.previousButton.alpha = 0.3
      }
        self.getDailyWeather(index:self.currentDay)

    }
    @IBAction func nextButtonOnClicked(_ sender: Any) {

              if(self.currentDay < self.weatherData.count - 1) {
                  self.currentDay += 1
                  self.previousButton.isEnabled = true
                  self.previousButton.alpha = 1
              } else {
                  self.nextButton.isEnabled = false
                  self.nextButton.alpha = 0.3
              }
        self.getDailyWeather(index:self.currentDay)
    }
    
      func getDailyWeather(index: Int){
           let daily = self.weatherData[index];
           
            DispatchQueue.main.async {
                URLSession.shared.dataTask(with: URL(string: "http://openweathermap.org/img/w/\(daily.weather[0].icon).png")!) { iconData, _ , _ in
                   if let data = iconData {
                      DispatchQueue.main.async {
                        self.weatherPictogram.image = UIImage(data: data)
                        self.setLabelValues(daily: daily)
                      }
                   }
                }.resume()
          }
        
}

func getWeatherData(cityName: String, lat : Double, lon : Double){
       let urlString = "https://api.openweathermap.org/data/2.5/onecall?lat=\(lat)&lon=\(lon)&%20&exclude=hourly,minutely,current&appid=f26652e3f203e7640c4d9ed4a4f74445"
       let url = URLRequest(url: URL(string: urlString)!)
       let task = URLSession.shared.dataTask(with: url){
                 (data:Data?, response:URLResponse?, error:Error?) in
                 if let data = data{
                   if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                       print(httpResponse.statusCode)
                            }
                   else{
                       do {
                           let decoder = JSONDecoder()
                           let decoded_data = try decoder.decode(WeatherData.self, from: data)
                        self.weatherData = decoded_data.daily
                        self.getDailyWeather(index: self.currentDay)
                       }catch {
                           print(error)
                       }
                   }
                 }
             }
             task.resume()
         }
    
    func setLabelValues(daily: Daily){
        let date = Date(timeIntervalSince1970: TimeInterval(daily.dt))
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "dd-MM-yyyy"
        self.city.text = self.name
        self.rain.text = "Rain: \(daily.rain ?? 0) mm"
        self.date.text = dateFormatter.string(from: date)
        self.weatherType.text = daily.weather[0].weatherDescription
        self.maxTemperature.text = "Max temp.: \(String(format: "%.2f", daily.temp.max - 272.15)) C"
        self.minTemperature.text = "Min temp.: \(String(format: "%.2f", daily.temp.min - 272.15)) C"
        self.wind.text = "Wind: \(String(format: "%.2f", daily.windSpeed * 3.6)) km/h \(self.convertDegreeToDirection(degree:daily.windDeg))"
        self.pressure.text = "Pressure: \(daily.pressure ) hPa"
        self.humidity.text = "Humidity: \(daily.humidity ) %"
    }
    
    func convertDegreeToDirection(degree:Int) -> String{
        let directions = ["N","N/NE","NE","E/NE","E","E/SE","SE","S/SE","S","S/SW","SW","W/SW","W","W/NW","NW","N/NW","N"];
        let index = round(Double(degree) / 22.5) 
        return directions[Int(index)]
    }
}

