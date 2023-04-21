//
//  CollectionViewController.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-20.
//

import UIKit

protocol PhotoCollectionDelegate {
    func photoHasBeenDeleted(_ photoViewController: PhotoViewController, index: Int)
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
    
    private let databaseContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            print("Error deleting photo")
            return }
        deletePhotoFromDatabase(index: index)
        
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        if savePhotoToDatabase() {
            dismiss(animated: true)
        }
    }
    
    func deletePhotoFromDatabase(index: Int) {
        databaseContext.delete(photos[index])
        photos.remove(at: index)
        collectionView.reloadData()
        delegate?.photoHasBeenDeleted(self, index: index)
    }
    
    func savePhotoToDatabase() -> Bool {
        if databaseContext.hasChanges {
            do {
                try databaseContext.save()
                return true
            } catch {
                print("Error saving workday to database = \(error)")
                return false
            }
        } else {
            return true
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
            photos[textView.tag].imageDescription = text
        }
    }
}
