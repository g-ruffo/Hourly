//
//  CollectionViewController.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-20.
//

import UIKit

protocol PhotoCollectionDelegate {
    func photoHasBeenDeleted(_ photoViewController: PhotoViewController)
}

class PhotoViewController: UIViewController {
    
    var photos: Array<PhotoItem> = []
    var startingRow: Int?
    var allowEditing = false
    private var hasSetToIndexPath = false
    
    var delegate: PhotoCollectionDelegate?
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var coreDataService: CoreDataService? { didSet { photos = coreDataService?.workdayPhotos ?? [] } }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        coreDataService?.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
        saveButton.isHidden = !allowEditing
        deleteButton.isHidden = !allowEditing
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !hasSetToIndexPath {
            collectionView.scrollToItem(at: IndexPath(row: startingRow!, section: 0), at: .top, animated: true)
            hasSetToIndexPath = true
        }
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        guard let index = collectionView.indexPathsForVisibleItems.first?.row else {
            print("Error deleting photo, unable to get index path")
            return
        }
        coreDataService?.deletePhoto(at: index)
        delegate?.photoHasBeenDeleted(self)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        if ((coreDataService?.saveToDatabase()) != nil) {
            dismiss(animated: true)
        }
    }
}


//MARK: - UICollectionViewDataSource
extension PhotoViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.Cell.photoCollectionCell, for: indexPath) as! PhotoCollectionCell
        
        if let photo = UIImage(data: (photos[indexPath.row].image)!) {
            cell.imageView.image = photo
        }
        cell.textView.text = photos[indexPath.row].imageDescription
        cell.textView.delegate = self
        cell.textView.tag = indexPath.row
        cell.setEditingState(allowEditing)
        return cell
    }
}

//MARK: - UICollectionViewFlowLayout
extension PhotoViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }
}

//MARK: - UITextViewDelegate
extension PhotoViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        if let text = textView.text {
            let index = textView.tag
            coreDataService?.updatePhoto(at: index, text: text)
        }
    }
}

//MARK: - CoreDataServiceDelegate
extension PhotoViewController: CoreDataServiceDelegate {
    func loadedPhotos(_ coreDataService: CoreDataService, photoItems: Array<PhotoItem>) {
        photos = photoItems
        DispatchQueue.main.async { self.collectionView.reloadData() }
    }
}
