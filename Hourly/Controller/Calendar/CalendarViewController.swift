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
    
    private let coreDataService = CoreDataService()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        coreDataService.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        
        loadWorkdaysFromDatabase()
        createCalendarGestureRecognizer()
        
        NotificationCenter.default.addObserver(self, selector: #selector(workdaysHaveBeenUpdated), name: K.NotificationKeys.updateWorkdaysNotification, object: nil)

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.Segue.calendarDetailNav {
            let destinationNav = segue.destination as? CalendarDetailController
            destinationNav?.workdays = (sender as? Array<WorkdayItem>)!
        }
    }
    
    @objc func workdaysHaveBeenUpdated(notification: NSNotification) {
        loadWorkdaysFromDatabase()
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
        if pan.direction == .right { setPreviousMonthSlide() }
        else if pan.direction == .left { setNextMonthSlide() }
    }
    
    func setMonthView(_ slideInDirection: CGFloat? = nil) {
        totalSquares.removeAll()
        let daysInMonth = manager.daysInMonth(date: selectedDate)
        let firstDayOfMonth = manager.firstOfMonth(date: selectedDate)
        let startingSpaces = manager.weekDay(date: firstDayOfMonth)
        let numberOfCells = (startingSpaces <= 4) || (startingSpaces <= 5 && daysInMonth < 31) ? 35 : 42
        var count: Int = 1
        while count <= numberOfCells {
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
        
        guard let direction = slideInDirection else {
            collectionView.reloadData()
            return
        }
        
        self.collectionView.alpha = 1

        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
            self.collectionView.center = CGPoint(x: self.collectionView.center.x - direction, y: self.collectionView.center.y)
            self.collectionView.reloadData()
        }
    }
    
    
    @IBAction func nextMonthPressed(_ sender: UIButton) { setNextMonthFade() }
    
    @IBAction func previousMonthPressed(_ sender: UIButton) { setPreviousMonthFade() }
    
    func setNextMonthFade() {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut) {
            self.collectionView.alpha = 0
            self.view.layoutIfNeeded()
        } completion: { completed in
            if completed {
                self.selectedDate = self.manager.plusMonth(date: self.selectedDate)
                self.loadWorkdaysFromDatabase(slideInDirection: 400)
            }
        }
    }
    
    func setPreviousMonthFade() {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut) {
            self.collectionView.alpha = 0
            self.view.layoutIfNeeded()
        } completion: { completed in
            if completed {
                self.selectedDate = self.manager.minusMonth(date: self.selectedDate)
                self.loadWorkdaysFromDatabase(slideInDirection: -400)
            }
        }
    }
    
    func setNextMonthSlide() {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
            self.collectionView.center.x = self.collectionView.center.x - 400
            self.view.layoutIfNeeded()
            
        } completion: { completed in
            if completed {
                self.selectedDate = self.manager.plusMonth(date: self.selectedDate)
                self.loadWorkdaysFromDatabase(slideInDirection: 400)
            }
        }
    }
    
    func setPreviousMonthSlide() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
            self.collectionView.center.x = self.collectionView.center.x + 400
            self.view.layoutIfNeeded()
        } completion: { completed in
            if completed {
                self.selectedDate = self.manager.minusMonth(date: self.selectedDate)
                self.loadWorkdaysFromDatabase(slideInDirection: -400)
            }
        }
    }
    
    func loadWorkdaysFromDatabase(slideInDirection: CGFloat? = nil) {
        let startDate = manager.firstOfMonth(date: selectedDate)
        let endDate = manager.lastOfMonth(date: selectedDate)
        let request: NSFetchRequest<WorkdayItem> = WorkdayItem.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date <= %@", startDate as NSDate, endDate as NSDate)
        coreDataService.getWorkdays(withRequest: request)
        setMonthView(slideInDirection)
    }
}

//MARK: - CalendarViewController

extension CalendarViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if totalSquares[indexPath.row].items.count > 0 {
            performSegue(withIdentifier: K.Segue.calendarDetailNav, sender: totalSquares[indexPath.row].items)
        }
    }
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

//MARK: - CoreDataServiceDelegate
extension CalendarViewController: CoreDataServiceDelegate {
        func loadedWorkdays(_ coreDataService: CoreDataService, workdayItems: Array<WorkdayItem>) {
            workdays = workdayItems
    }
}


