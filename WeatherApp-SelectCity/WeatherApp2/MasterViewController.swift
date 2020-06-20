//
//  MasterViewController.swift
//  WeatherApp2
//
//  Created by Ania Wójcik on 15/06/2020.
//  Copyright © 2020 Ania Wójcik. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController,NewCityDelegate{

    var gradientLayer: CAGradientLayer!
    var cities: Cities = Cities()
    var weatherData : [Daily] = []
    var detailViewController: DetailViewController? = nil
    var objects = [Any]()


    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem

        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        self.getWeatherData(cityName: cities.city[0].cityName,lat:cities.city[0].lat,lon:cities.city[0].lon)
        self.getWeatherData(cityName: cities.city[1].cityName,lat:cities.city[1].lat,lon:cities.city[1].lon)
        self.getWeatherData(cityName: cities.city[2].cityName,lat:cities.city[2].lat,lon:cities.city[2].lon)
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        let gradientView = GradientView(frame: self.view.bounds)
        self.tableView.backgroundView = gradientView
        super.viewWillAppear(animated)
    }

    @objc
    func insertNewObject(cityName: String) {
        DispatchQueue.main.async {
            self.objects.insert(cityName, at: 0)
            let indexPath = IndexPath(row: 0, section: 0)
            self.tableView.insertRows(at: [indexPath], with: .automatic)
        }
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = objects[indexPath.row] as! NSString
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                detailViewController = controller
            }
        }
        if segue.identifier == "getDataSegue" {
            let secondVC: ModalAddCityController = segue.destination as! ModalAddCityController
            secondVC.delegate = self
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let daily = self.weatherData[0];
        let object = objects[indexPath.row] as! String
     
          DispatchQueue.main.async {
              URLSession.shared.dataTask(with: URL(string: "http://openweathermap.org/img/w/\(daily.weather[0].icon).png")!) { iconData, _ , _ in
                           if let data = iconData {
                              DispatchQueue.main.async {
                              cell.imageView?.image = UIImage(data: data)
                              }
                           }
                        }.resume()
                  }
        cell.textLabel!.text = "\(object.description)    \(String(format: "%.2f", daily.temp.max - 272.15)) C"
        cell.backgroundColor = .clear
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            objects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
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
                            self.insertNewObject(cityName: cityName)
                           }catch {
                               print(error)
                           }
                       }
                     }
                 }
                 task.resume()
             }
    
    func cityData(cityName: String) {
        let index = cities.city.firstIndex(where: {($0.cityName == cityName)})
        self.getWeatherData(cityName:cityName,lat:cities.city[index ?? 0].lat,lon:cities.city[index ?? 0].lon)
    }
}

