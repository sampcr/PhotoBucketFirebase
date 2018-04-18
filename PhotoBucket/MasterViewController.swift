//
//  MasterViewController.swift
//  PhotoBucket
//
//  Created by Christopher Samp on 4/16/18.
//  Copyright © 2018 Christopher Samp. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var context: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    let photoBucketCellIdentifier = "PhotoBucketCell"
    let showDetailSegueIdentifier = "ShowDetailSegue"
    let names = ["Fire!", "Blue Lightning", "Wow!", "Lightning"]
    var photoBuckets = [Photo]()


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.leftBarButtonItem = editButtonItem

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
//        let photo1:Photo = Photo(context: self.context)
//        photo1.created = Date()
//        photo1.caption = "Fire!"
//        photo1.url = "abc.com"
//        photoBuckets.append(photo1)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        self.updatePhotoBucketArray()
        tableView.reloadData()
    }



    @objc
    func insertNewObject(_ sender: Any) {
        let alertController = UIAlertController(title: "Create a new WeatherPic", message: "", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Caption"
        }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Image URL or none"
        }
        
        let cancelAction = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        
        let createQuotesAction = UIAlertAction(title: "Create", style: .default) { (action) in
            let captionTextField = alertController.textFields![0]
            let urlTextField = alertController.textFields![1]
            let newPhotoBucket = Photo(context: self.context)
            newPhotoBucket.caption = captionTextField.text
            if(urlTextField.text == "") {
                newPhotoBucket.url = "https://upload.wikimedia.org/wikipedia/commons/0/04/Hurricane_Isabel_from_ISS.jpg"
            } else {
                newPhotoBucket.url = urlTextField.text
            }
            newPhotoBucket.created = Date()
//            self.photoBuckets.append(newPhotoBucket)
            self.save()
            self.updatePhotoBucketArray()
            self.tableView.reloadData()
            
        }
        alertController.addAction(cancelAction)
        alertController.addAction(createQuotesAction)
        
        present(alertController, animated: true, completion: nil)
    }

    
    func updatePhotoBucketArray() {
        // make a fetch request
        // execute the request in a try catch block
        print("updating array")
        let request: NSFetchRequest<Photo> = Photo.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "created", ascending: false)]
        
        do {
            photoBuckets = try context.fetch(request)
            print("photobuckets: \(photoBuckets)")
        } catch {
            fatalError("Unresolved Core Data Error")
        }
    }
    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailView" {
            if let indexPath = tableView.indexPathForSelectedRow {
                (segue.destination as! DetailViewController).photo = photoBuckets[indexPath.row]
            }
        }
    }
    
    func save() {
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photoBuckets.count
//        return max(photoBuckets.count,1)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = photoBuckets[indexPath.row].caption
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return photoBuckets.count > 0
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            context.delete(photoBuckets[indexPath.row])
            self.save()
            updatePhotoBucketArray()
            
            tableView.reloadData()
        }
    }
}

