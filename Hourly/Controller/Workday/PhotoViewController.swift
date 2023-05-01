//
//  CollectionViewController.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-20.
//

import UIKit

protocol PhotoCollectionDelegate: AnyObject {
    func photoHasBeenDeleted(_ photoViewController: PhotoViewController)
    func finishedEditing(_ photoViewController: PhotoViewController)
}

class PhotoViewController: UIViewController {
    // MARK: - Variables
    var photos: Array<PhotoItem> = []
    var startingRow: Int?
    var allowEditing = false
    private var hasSetToIndexPath = false
    weak var delegate: PhotoCollectionDelegate?
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    // Once the service is set, pass the current photos into the array for display.
    var coreDataService: CoreDataService? { didSet { photos = coreDataService?.workdayPhotos ?? [] } }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the delegates and data source.
        coreDataService?.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
        saveButton.isHidden = !allowEditing
        deleteButton.isHidden = !allowEditing
        collectionView.contentInsetAdjustmentBehavior = .never
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !hasSetToIndexPath {
            // Scroll to the photo selected by the user.
            collectionView.scrollToItem(at: IndexPath(row: startingRow!, section: 0), at: .top, animated: true)
            hasSetToIndexPath = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.finishedEditing(self)
    }
    
    // Called when the trailing navigation bar button is pressed.
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        // Get the index of the current displayed photo item.
        guard let index = collectionView.indexPathsForVisibleItems.first?.row else {
            print("Error deleting photo, unable to get index path")
            return
        }
        // Delete the item and notify the delegate of the change.
        coreDataService?.deletePhoto(at: index)
        delegate?.photoHasBeenDeleted(self)
    }
    // Called when the leading navigation bar button is pressed.
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        // Save changes to database and navigate back if successful.
        if ((coreDataService?.saveToDatabase()) != nil) {
            dismiss(animated: true)
        }
    }
}
// MARK: - UICollectionViewDataSource
extension PhotoViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.Cell.photoCollectionCell, for: indexPath) as! PhotoCollectionCell
        // If the photo items photo is valid set it to the cells image view.
        let imageData = photos[indexPath.row].image
        if let image = imageData {
            let uiImage = UIImage(data: image)
            cell.imageView.image = uiImage
        } else {
            cell.imageView.image = UIImage(systemName: "externaldrive.badge.questionmark")
        }
        cell.textView.text = photos[indexPath.row].imageDescription
        // Set the cells delegate as self to listen for changes in the text view.
        cell.textView.delegate = self
        cell.textView.tag = indexPath.row
        cell.setEditingState(allowEditing)
        return cell
    }
}
// MARK: - UICollectionViewFlowLayout
extension PhotoViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Set the cells width and height to match the collection views frame.
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }
}
// MARK: - UITextViewDelegate
extension PhotoViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        // Check to see if changes to the text view are valid and if so update the photo item.
        if let text = textView.text {
            let index = textView.tag
            coreDataService?.updatePhoto(at: index, text: text)
        }
    }
}
// MARK: - CoreDataServiceDelegate
extension PhotoViewController: CoreDataServiceDelegate {
    func loadedPhotos(_ coreDataService: CoreDataService, photoItems: Array<PhotoItem>) {
        photos = photoItems
        if photoItems.count < 1 { dismiss(animated: true) }
        DispatchQueue.main.async { self.collectionView.reloadData() }
    }
}
