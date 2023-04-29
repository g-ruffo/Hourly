//
//  CalendarViewController.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-10.
//

import UIKit
import CoreData

class CalendarViewController: UIViewController {
    // MARK: - Variables
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
        // Set delegates and datasource to self.
        coreDataService.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        
        loadWorkdaysFromDatabase()
        createCalendarGestureRecognizer()
        // Add observer to notify controller if a new workday has been added.
        NotificationCenter.default.addObserver(self, selector: #selector(workdaysHaveBeenUpdated), name: K.NotificationKeys.updateWorkdaysNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.Navigation.calendarDetailNav {
            let destinationNav = segue.destination as? CalendarDetailController
            // Sets the workdays to be displayed on the detail view controller.
            destinationNav?.workdays = (sender as? Array<WorkdayItem>)!
        }
    }
    
    // If new workday has been added reload workdays from database.
    @objc func workdaysHaveBeenUpdated(notification: NSNotification) {
        loadWorkdaysFromDatabase()
    }
    
    // Listen for swipe events and if detected change the current month.
    private func createCalendarGestureRecognizer() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(onSwipe(_:)))
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(onSwipe(_:)))
        swipeLeft.direction = .left
        swipeRight.direction = .right
        collectionView.addGestureRecognizer(swipeLeft)
        collectionView.addGestureRecognizer(swipeRight)
    }
    
    @objc func onSwipe(_ pan: UISwipeGestureRecognizer) {
        // If user swipes right, go back one month.
        if pan.direction == .right { setPreviousMonthSlide() }
        // If user swipes left, go forward one month.
        else if pan.direction == .left { setNextMonthSlide() }
    }
    
    func setMonthView(_ slideInDirection: CGFloat? = nil) {
        totalSquares.removeAll()
        let daysInMonth = manager.daysInMonth(date: selectedDate)
        let firstDayOfMonth = manager.firstOfMonth(date: selectedDate)
        let startingSpaces = manager.weekDay(date: firstDayOfMonth)
        // Set the cell count based on the number of days in the given month.
        let numberOfCells = (startingSpaces <= 4) || (startingSpaces <= 5 && daysInMonth < 31) ? 35 : 42
        var count: Int = 1
        while count <= numberOfCells {
            if(count <= startingSpaces || count - startingSpaces > daysInMonth) {
                totalSquares.append((day: "", items: []))
            } else {
                let dayOfMonth = count - startingSpaces
                // Add the days worked to cell.
                let daysWorked = workdays.filter { $0.date?.get(.day) == dayOfMonth }
                totalSquares.append((day: String(dayOfMonth), items: daysWorked))
            }
            count += 1
        }
        // Set the month title label.
        monthLabel.text = manager.monthString(date: selectedDate) + " " + manager.yearString(date: selectedDate)
        // If slide direction is nil, the user has just loaded the screen.
        guard let direction = slideInDirection else {
            self.collectionView.reloadData()
            return
        }
        self.collectionView.alpha = 1
        // Animate the new month cells in the same direction as the removed ones.
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
            self.collectionView.center = CGPoint(x: self.collectionView.center.x - direction, y: self.collectionView.center.y)
            DispatchQueue.main.async { self.collectionView.reloadData() }
        }
    }
    
    // Called when next month arrow is pressed.
    @IBAction func nextMonthPressed(_ sender: UIButton) { setNextMonthFade() }
    // Called when previous month arrow is pressed.
    @IBAction func previousMonthPressed(_ sender: UIButton) { setPreviousMonthFade() }
    
    func setNextMonthFade() {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut) {
            self.collectionView.alpha = 0
            self.view.layoutIfNeeded()
        } completion: { completed in
            if completed {
                // Slide in the new cells when animation is completed.
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
            // Slide in the new cells when animation is completed.
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
            // Slide in the new cells when animation is completed.
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
            // Slide in the new cells when animation is completed.
            if completed {
                self.selectedDate = self.manager.minusMonth(date: self.selectedDate)
                self.loadWorkdaysFromDatabase(slideInDirection: -400)
            }
        }
    }
    
    func loadWorkdaysFromDatabase(slideInDirection: CGFloat? = nil) {
        // Create a fetch request using the first and last day of the selected month as a filter.
        let startDate = manager.firstOfMonth(date: selectedDate)
        let endDate = manager.lastOfMonth(date: selectedDate)
        let request: NSFetchRequest<WorkdayItem> = WorkdayItem.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date <= %@", startDate as NSDate, endDate as NSDate)
        coreDataService.getWorkdays(withRequest: request)
        // Notify the collection view which direction to slide in from.
        setMonthView(slideInDirection)
    }
}

// MARK: - CalendarViewController
extension CalendarViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        // Only allow user to perform segue if the selected day has associated workdays.
        if totalSquares[indexPath.row].items.count > 0 {
            performSegue(withIdentifier: K.Navigation.calendarDetailNav, sender: totalSquares[indexPath.row].items)
        }
    }
}

// MARK: - CalendarViewController
extension CalendarViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalSquares.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.Cell.calendarCell, for: indexPath) as! CalendarCell
        
        let dayObject = totalSquares[indexPath.item]
        // If the cell date matches todays date add blue circle around the label.
        if selectedDate.get(.year, .month) == todaysDate.get(.year, .month){
            if let today = Int(dayObject.day), today == todaysDate.get(.day) {
                cell.dayOfMonthLabel.backgroundColor = .systemCyan.withAlphaComponent(0.4) }
        } else { cell.dayOfMonthLabel.backgroundColor = .clear }
        
        cell.configure(title: dayObject.day, with: dayObject.items)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CalendarViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Set the size of each cell based on the users screen size.
        return CGSize(width: (floor(self.collectionView.bounds.width - 9)) / 7, height: (self.collectionView.bounds.height) / 6)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
}

// MARK: - CoreDataServiceDelegate
extension CalendarViewController: CoreDataServiceDelegate {
    func loadedWorkdays(_ coreDataService: CoreDataService, workdayItems: Array<WorkdayItem>) {
        workdays = workdayItems
    }
}


