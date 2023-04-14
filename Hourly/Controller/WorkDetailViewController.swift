//
//  WorkDetailViewController.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-14.
//

import UIKit

class WorkDetailViewController: UIViewController {
    
    @IBOutlet weak var clientLabel: UILabel!
    @IBOutlet weak var earningsLabel: UILabel!
    @IBOutlet weak var draftButton: UIButton!
    @IBOutlet weak var photosView: UIView!
    @IBOutlet weak var photosCollectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func editButtonPressed(_ sender: UIButton) {
    }
    
}
