//
//  CalendarViewController.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-10.
//

import UIKit

class CalendarViewController: UIViewController {
    
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var isDisplayingCalendar = true
        
    private let workDays: Array<WorkDayItem> = []
    
    private let testDays: Array<TestDay> = [
    TestDay(),
    TestDay(),
    TestDay(),
    TestDay(),
    TestDay(),
    TestDay(),
    TestDay(),
    TestDay(),
    TestDay(),
    TestDay(),
    TestDay(),
    TestDay()]

    
    let databaseContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Connect required delegates
        collectionView.delegate = self
//        collectionView.dataSource = self
        
        // Register custom work day cell with table view
    }
    
    
    @IBAction func nextMonthPressed(_ sender: UIButton) {
    }
    
    @IBAction func previousMonthPressed(_ sender: UIButton) {
    }
}

//MARK: - CalendarViewController

extension CalendarViewController: UICollectionViewDelegate {
}


//MARK: - CalendarViewController

//extension CalendarViewController: UICollectionViewDataSource {
//
//}





