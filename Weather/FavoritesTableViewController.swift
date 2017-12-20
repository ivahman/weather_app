//
//  PlacesTableViewController.swift
//  Weather
//
//  Created by Dmytro Ivakhnenko on 05.11.17.
//  Copyright © 2017 Dmytro Ivakhnenko. All rights reserved.
//

import UIKit
import Aeris
import CoreData

class FavoritesTableViewController: UITableViewController, UISplitViewControllerDelegate {

    var container: NSPersistentContainer? = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    
    private var fetchResultController: NSFetchedResultsController<Place>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()
        
        splitViewController?.delegate = self
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        
        return true
    }
    
    private func updateUI() {
        
        if let context = container?.viewContext {
            let fetchRequest: NSFetchRequest<Place> = Place.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "added", ascending: false)]
            
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultController.delegate = self
            
            do {
                try fetchResultController.performFetch()
            } catch {
                fatalError("Failed to fetch entities: \(error)")
            }
            
            tableView.reloadData()
            performSegue(withIdentifier: "showForecastForAddedPlace", sender: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let sections = fetchResultController.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath)
        
        guard let place = fetchResultController?.object(at: indexPath) else {
            fatalError("Attempt to configure cell without a managed object")
        }

        cell.textLabel?.text = place.name

        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            fetchResultController.managedObjectContext.delete(fetchResultController.object(at: indexPath))
            try? fetchResultController.managedObjectContext.save()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showForecastForSelectedPlace" {
            if let indexPath = tableView.indexPathForSelectedRow {
                if let forecastVC = segue.destinationVC as? ForecastViewController {
                    forecastVC.place = fetchResultController.object(at: indexPath)
                }
            }
        }
        
        if segue.identifier == "showForecastForAddedPlace" {
            if let forecastVC = segue.destinationVC as? ForecastViewController {
                guard let place = fetchResultController.fetchedObjects?.first else {
                    print("Can not get object for new added place")
                    return
                }
                forecastVC.place = place
            }
        }
    }
    
    @IBAction func addNewPlace(segue: UIStoryboardSegue) {
        
        if let sourceVC = segue.source as? AddPlaceViewController {
            if let selectedPlace = sourceVC.selectedPlace {
                updateDatabase(selectedPlace)
            }
        }
    }
    
    private func updateDatabase(_ awfPlace: AWFPlace) {
        
        container?.performBackgroundTask{ [weak self] context in
            guard let place = try? Place.createOrUpdate(awfPlace, in: context) else {
                return
            }
            try? context.save()
            self?.updateUI()
        }
    }
}

extension UIStoryboardSegue {
    
    var destinationVC: UIViewController {
        get {
            if let navigationController = destination as? UINavigationController {
                return navigationController.visibleViewController ?? self.destination
            }
            return self.destination
        }
    }
}

extension FavoritesTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .automatic)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        case .move:
            if let fromIndexPath = indexPath, let toIndexPath = newIndexPath {
                tableView.deleteRows(at: [fromIndexPath], with: .automatic)
                tableView.insertRows(at: [toIndexPath], with: .automatic)
            }
        case .update:
            if let indexPath = indexPath {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }
}
