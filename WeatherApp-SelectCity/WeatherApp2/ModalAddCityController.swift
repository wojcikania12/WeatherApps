//
//  ModalAddCityController.swift
//  WeatherApp2
//
//  Created by Ania Wójcik on 16/06/2020.
//  Copyright © 2020 Ania Wójcik. All rights reserved.
//

import UIKit

protocol NewCityDelegate{
  func cityData(cityName: String)
}

class ModalAddCityController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var objects = [String]()
    var cities: Cities = Cities()

    @IBOutlet weak var foundCities: UITableView!
    @IBOutlet weak var input: UITextField!
    var delegate: NewCityDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.foundCities.dataSource = self
        self.foundCities.delegate = self
        let gradientView = GradientView(frame: self.view.bounds)
        self.view.insertSubview(gradientView, at: 0)
        self.foundCities.backgroundColor = .clear
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: false, completion:nil)
    }
    
    @IBAction func search(_ sender: Any) {
        self.objects.removeAll()
        self.foundCities.reloadData()
        let regex = "^(\(self.input.text?.lowercased() ?? ""))*"
        for city in cities.city{
            let found = self.matches(for: regex, in: city.cityName.lowercased())
            if(!found.isEmpty){
                if(found[0] != ""){
                self.objects.insert(city.cityName, at: 0)
                let indexPath = IndexPath(row: 0, section: 0)
                self.foundCities.insertRows(at: [indexPath], with: .automatic)
                }
            }
         }
    }
    
    func matches(for regex: String, in text: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt
       indexPath: IndexPath) {
       self.delegate?.cityData(cityName: self.objects[indexPath.row])
       self.presentingViewController?.dismiss(animated: false, completion:nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let object = self.objects[indexPath.row]
        cell.textLabel!.text = object.description
        cell.textLabel?.textColor = .white
        cell.backgroundColor = .clear
        return cell
    }
}

