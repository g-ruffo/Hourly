//
//  CollectionViewController.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-20.
//

import UIKit

class PhotoViewController: UIViewController {
    
    var photos: Array<PhotoItem> = []
    var startingIndexPath: IndexPath?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.scrollToItem(at: startingIndexPath!, at: .centeredVertically, animated: true)
    }
}


//MARK: - UICollectionViewDataSource
extension PhotoViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("photos.count = \(photos.count)")

        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.Cell.photoCollectionCell, for: indexPath) as! PhotoCollectionCell
        
        if let photo = UIImage(data: (photos[indexPath.row].image)!) {
            cell.imageView.image = photo
        }
                               
        cell.textView.text = photos[indexPath.row].imageDescription
        
        return cell
    }
    

    
}

//MARK: - UICollectionViewDelegate
extension PhotoViewController: UICollectionViewDelegate {
    
}

//MARK: - UICollectionViewFlowLayout
extension PhotoViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenSize = UIScreen.main.bounds
        return CGSize(width: screenSize.width, height: screenSize.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
