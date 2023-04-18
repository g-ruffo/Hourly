//
//  WorkDetailViewController.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-14.
//

import UIKit

protocol EditWorkdayDelegate {
    func editWorkday(_ workDetailViewController: WorkDetailViewController, workday: WorkdayItem)
}

class WorkDetailViewController: UIViewController {
    
    @IBOutlet weak var draftButton: UIButton!
    @IBOutlet weak var photosCollectionView: UICollectionView!
    
    //MARK: - Fields to set
    @IBOutlet weak var clientLabel: UILabel!
    @IBOutlet weak var earningsLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var lunchTimeLabel: UILabel!
    @IBOutlet weak var hoursWorkedLabel: UILabel!
    @IBOutlet weak var payRateLabel: UILabel!
    @IBOutlet weak var mileageLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    var workday: WorkdayItem?
    
    var delegate: EditWorkdayDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photosCollectionView.delegate = self
        photosCollectionView.dataSource = self


        // Do any additional setup after loading the view.
    }
    

    @IBAction func editButtonPressed(_ sender: UIButton) {
            self.dismiss(animated: true) {
                guard let editWorkday = self.workday else {
                    fatalError("Unable to get workday to edit")
                }
                self.delegate?.editWorkday(self, workday: editWorkday)
            }
    }
    
}

//MARK: - UICollectionViewDataSource

extension WorkDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.Cell.workdayImageCell, for: indexPath) as! WordayImageCell
        return cell
    }
    
    
}

//MARK: - UICollectionViewDelegate

extension WorkDetailViewController: UICollectionViewDelegate {
    
}
