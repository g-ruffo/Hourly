//
//  CollectionViewController.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-20.
//

import UIKit

class PhotoViewController: UIViewController {
    
    var photos: Array<PhotoItem> = []
    var startingRow: Int?
    var allowEditing = false
    private var hasSetToIndexPath = false
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
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
        cell.setEditingState(allowEditing)
        return cell
    }
}

//MARK: - UICollectionViewDelegate
extension PhotoViewController: UICollectionViewDelegate {
    
}

//MARK: - UICollectionViewFlowLayout
extension PhotoViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }
}
