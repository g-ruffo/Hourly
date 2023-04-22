//
//  CalendarViewController.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-10.
//

import UIKit
import CoreData

class CalendarViewController: UIViewController {
    
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var selectedDate = Date()
    private var totalSquares: Array<(day: String, items: [WorkdayItem])> = []
    private var todaysDate = Date()
    
    private let manager = CalendarManager()
            
    private var workdays: Array<WorkdayItem> = []
    
    let databaseContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
    
        loadWorkdayFromDatabase()
        createCalendarGestureRecognizer()

    }
    
    private func createCalendarGestureRecognizer() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(onSwipe(_:)))
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(onSwipe(_:)))
        
        swipeLeft.direction = .left
        swipeRight.direction = .right
        
        collectionView.addGestureRecognizer(swipeLeft)
        collectionView.addGestureRecognizer(swipeRight)
    }
    
    @objc func onSwipe(_ pan: UISwipeGestureRecognizer) {
        if pan.direction == .right {
            selectedDate = manager.minusMonth(date: selectedDate)
            loadWorkdayFromDatabase()
        } else if pan.direction == .left {
            selectedDate = manager.plusMonth(date: selectedDate)
            loadWorkdayFromDatabase()
        }
    }
    
    func setMonthView() {
        totalSquares.removeAll()
        let daysInMonth = manager.daysInMonth(date: selectedDate)
        let firstDayOfMonth = manager.firstOfMonth(date: selectedDate)
        let startingSpaces = manager.weekDay(date: firstDayOfMonth)
        
        var count: Int = 1
        while count <= 42 {
            if(count <= startingSpaces || count - startingSpaces > daysInMonth) {
                totalSquares.append((day: "", items: []))
            } else {
                let dayOfMonth = count - startingSpaces
                let daysWorked = workdays.filter { $0.date?.get(.day) == dayOfMonth }
                totalSquares.append((day: String(dayOfMonth), items: daysWorked))
            }
            count += 1
        }
        monthLabel.text = manager.monthString(date: selectedDate) + " " + manager.yearString(date: selectedDate)
        collectionView.reloadData()
    }
    
    
    @IBAction func nextMonthPressed(_ sender: UIButton) {
        selectedDate = manager.plusMonth(date: selectedDate)
        loadWorkdayFromDatabase()
    }
    
    @IBAction func previousMonthPressed(_ sender: UIButton) {
        selectedDate = manager.minusMonth(date: selectedDate)
        loadWorkdayFromDatabase()
    }
    
    func loadWorkdayFromDatabase() {
        let startDate = manager.firstOfMonth(date: selectedDate)
        let endDate = manager.lastOfMonth(date: selectedDate)
        let request: NSFetchRequest<WorkdayItem> = WorkdayItem.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date <= %@", startDate as NSDate, endDate as NSDate)
        do{
            workdays = try databaseContext.fetch(request)
            setMonthView()
        } catch {
            print("Error fetching clients from database = \(error)")
        }
    }
}

//MARK: - CalendarViewController

extension CalendarViewController: UICollectionViewDelegate {
}


//MARK: - CalendarViewController
extension CalendarViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalSquares.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.Identifiers.calendarCell, for: indexPath) as! CalendarCell
        
        let dayObject = totalSquares[indexPath.item]
        if selectedDate.get(.year, .month) == todaysDate.get(.year, .month){
            if let today = Int(dayObject.day), today == todaysDate.get(.day) {
                cell.dayOfMonthLabel.backgroundColor = .systemCyan.withAlphaComponent(0.4)
            }
        } else {
            cell.dayOfMonthLabel.backgroundColor = .clear
        }
        cell.configure(title: dayObject.day, with: dayObject.items)
        
        return cell
    }

}

//MARK: - UICollectionViewDelegateFlowLayout
extension CalendarViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (floor(self.collectionView.bounds.width - 9)) / 7, height: (self.collectionView.bounds.height) / 5)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
}




