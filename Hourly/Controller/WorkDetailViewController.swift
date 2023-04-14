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
    
    var workday: WorkDayItem?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photosCollectionView.delegate = self
        photosCollectionView.dataSource = self


        // Do any additional setup after loading the view.
    }
    

    @IBAction func editButtonPressed(_ sender: UIButton) {
    }
    
}

//MARK: - UICollectionViewDataSource

extension WorkDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        <#code#>
    }
    
    
}

//MARK: - UICollectionViewDelegate

extension WorkDetailViewController: UICollectionViewDelegate {
    
}
