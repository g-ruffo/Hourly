//
//  WorkDetailViewController.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-14.
//

import UIKit

protocol EditWorkdayDelegate: AnyObject {
    func editWorkday(_ workDetailViewController: WorkDetailViewController, workday: WorkdayItem)
}

class WorkDetailViewController: UIViewController {
    // MARK: - Variables
    @IBOutlet weak var draftButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
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
    private let manager = WorkdayDetailsManager()
    private var savedPhotos: Array<PhotoItem> = []
    var workday: WorkdayItem?
    weak var delegate: EditWorkdayDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the delegate and data source.
        collectionView.delegate = self
        collectionView.dataSource = self
        setWorkdayDetails()
        collectionView.register(PhotoCell.nib(), forCellWithReuseIdentifier: K.Cell.photoCell)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.Navigation.detailsPhotoCollectionNav {
            let destinationVC = segue.destination as? PhotoViewController
            // Pass the workdays photos to the destination view controller.
            destinationVC?.photos = savedPhotos
            // Pass the index of the selected photo to the destination view controller.
            destinationVC?.startingRow = sender as? Int
        }
    }
    // Load the selected workday and set the corresponding text fields values.
    private func setWorkdayDetails() {
        guard let day = workday else {
            print("Unable to get work day")
            return
        }
        clientLabel.text = day.clientName
        earningsLabel.text = day.earnings.convertToCurrency()
        dateLabel.text = day.date?.formatDateToString() ?? "No date set"
        draftButton.isHidden = day.isFinalized
        startTimeLabel.text = manager.timeToDisplayString(day.startTime)
        endTimeLabel.text = manager.timeToDisplayString(day.endTime)
        lunchTimeLabel.text = "\(day.lunchMinutes) min"
        hoursWorkedLabel.text = Helper.minutesToHoursWorkedString(minutesWorked: day.minutesWorked)
        payRateLabel.text = day.payRate.convertToCurrency()
        mileageLabel.text = "\(day.mileage) km"
        if let description = day.workDescription, description.isEmpty {
            descriptionLabel.text = "No description found"
        } else {
            descriptionLabel.text = day.workDescription
        }
        if let location = day.location, location.isEmpty {
            locationLabel.text = "No location set"
        } else {
            locationLabel.text = day.location
        }
        // If there are no photos associated with the workday hide the collection view.
        savedPhotos = day.photos?.allObjects as? Array<PhotoItem> ?? []
        collectionView.isHidden = savedPhotos.count < 1
    }
    // Called when the trailing navigation bar button is pressed.
    @IBAction func editButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true) {
            guard let editWorkday = self.workday else {
                print("Unable to get workday to edit")
                return
            }
            self.delegate?.editWorkday(self, workday: editWorkday)
        }
    }
}
// MARK: - UICollectionViewDataSource
extension WorkDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return savedPhotos.count
    }
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.Cell.photoCell, for: indexPath) as! PhotoCell
        if let image = UIImage(data: savedPhotos[indexPath.row].image!) {
            cell.imageView.image = image
        } else {
            // If image cant be retrieved set the image as a question mark.
            cell.imageView.image = UIImage(systemName: "externaldrive.badge.questionmark")
        }
        return cell
    }
}
// MARK: - UICollectionViewDelegate
extension WorkDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: K.Navigation.detailsPhotoCollectionNav, sender: indexPath.row)
    }
}
// MARK: - UICollectionViewDelegateFlowLayout
extension WorkDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 110, height: 110)
    }
}
