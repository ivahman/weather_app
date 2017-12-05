//
//  AddNewPlaceViewController.swift
//  Weather
//
//  Created by Dmytro Ivakhnenko on 19.11.17.
//  Copyright © 2017 Dmytro Ivakhnenko. All rights reserved.
//

import UIKit
import Aeris

class AddPlaceViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    
    private let loader: AWFPlacesLoader = AWFPlacesLoader()
    private var places = [AWFPlace]()
    
    var selectedPlace: AWFPlace?
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func done(_ sender: UIBarButtonItem) {
        
        if selectedPlace != nil {
            performSegue(withIdentifier: "addNewPlaceDone", sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cityCell")!
        let place = places[indexPath.row]
        cell.textLabel?.text = place.name
        cell.detailTextLabel?.text = place.countryFull
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        selectedPlace = places[indexPath.row]
    }
    
    @IBAction func textFieldEditing(_ sender: UITextField) {
        
        loadPlace(with: sender.text!)
    }
    
    private func loadPlace(with name: String) {
        
        if loader.isLoading {
            loader.cancel()
        }
        
        let options = AWFRequestOptions()
        options.limit = 100
        
        loader.searchForPlaceWithNameStarting(with: name, options: options) { [weak self] (objects, error) in
            if let error = error {
                print("places data failed to load! \(error)")
                return
            }
            
            if let places = objects as? Array<AWFPlace> {
                self?.places = places
                self?.tableView.reloadData()
            }
        }
    }
}
