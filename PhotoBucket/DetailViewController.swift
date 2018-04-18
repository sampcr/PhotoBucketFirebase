//
//  DetailViewController.swift
//  PhotoBucket
//
//  Created by Christopher Samp on 4/16/18.
//  Copyright © 2018 Christopher Samp. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var captionLabel: UILabel!
    
    var photo: Photo?
    
    func configureView() {
        // Update the user interface for the detail item.
        captionLabel.text = photo?.caption
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(showEditDialog))
        
        configureView()
    }
    
    @objc func showEditDialog() {
        let alertController = UIAlertController(title: "Edit Caption", message: "", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "caption"
            textField.text = self.photo?.caption
        }
        
        let cancelAction = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        
        let createQuotesAction = UIAlertAction(title: "edit", style: .default) { (action) in
            let captionTextField = alertController.textFields![0]
            self.photo?.caption = captionTextField.text!
            self.configureView()
            
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(createQuotesAction)
        
        present(alertController, animated: true, completion: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.captionLabel.text = self.photo?.caption
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("int view did appear")
        if let imgString = photo?.url {
            if let imgUrl = URL(string: imgString) {
                DispatchQueue.global().async { // Download in the background
                    do {
                        let data = try Data(contentsOf: imgUrl)
                        DispatchQueue.main.async { // Then update on main thread
                            print("updated the image")
                            self.image.image = UIImage(data: data)
                        }
                    } catch {
                        print("Error downloading image: \(error)")
                    }
                }
            }
        }
    }


    var detailItem: Photo? {
        didSet {
            captionLabel.text = photo?.caption
            configureView()
        }
    }


}

