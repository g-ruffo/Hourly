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
    
    private var selectedDate = Date()
    private var totalSquares = [String]()
    
    private let calendarManager = CalendarManager()
            
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
        collectionView.delegate = self
        collectionView.dataSource = self
    
        setCellsView()
        setMonthView()
        createCalendarGestureRecognizer()
    }
    
    private func createCalendarGestureRecognizer() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(onPan(_:)))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        collectionView.addGestureRecognizer(swipeLeft)
                let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(onPan(_:)))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        collectionView.addGestureRecognizer(swipeRight)
    }
    
    @objc func onPan(_ pan: UISwipeGestureRecognizer) {
        if pan.direction == .right {
            selectedDate = calendarManager.minusMonth(date: selectedDate)
            setMonthView()
        } else if pan.direction == .left {
            selectedDate = calendarManager.plusMonth(date: selectedDate)
            setMonthView()
        }
    }
    
    func setCellsView() {
        let width = (collectionView.frame.size.width - 2) / 8
        let height = (collectionView.frame.size.height - 2) / 8
        
        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.itemSize = CGSize(width: width, height: height)

    }
    
    func setMonthView() {
        totalSquares.removeAll()
        let daysInMonth = calendarManager.daysInMonth(date: selectedDate)
        let firstDayOfMonth = calendarManager.firstOfMonth(date: selectedDate)
        let startingSpaces = calendarManager.weekDay(date: firstDayOfMonth)
        
        var count: Int = 1
        while count <= 42 {
            if(count <= startingSpaces || count - startingSpaces > daysInMonth) {
                totalSquares.append("")
            } else {
                totalSquares.append(String(count - startingSpaces))
            }
            count += 1
        }
        monthLabel.text = calendarManager.monthString(date: selectedDate) + " " + calendarManager.yearString(date: selectedDate)
        collectionView.reloadData()
    }
    
    
    @IBAction func nextMonthPressed(_ sender: UIButton) {
        selectedDate = calendarManager.plusMonth(date: selectedDate)
        setMonthView()
    }
    
    @IBAction func previousMonthPressed(_ sender: UIButton) {
        selectedDate = calendarManager.minusMonth(date: selectedDate)
        setMonthView()
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
        
        cell.dayOfMonthLabel.text = totalSquares[indexPath.item]
        if !totalSquares[indexPath.item].isEmpty {
//            let image = UIImageView(image: UIImage(systemName: "square.fill"))
//            image.tintColor = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
//
//            image.translatesAutoresizingMaskIntoConstraints = false
//
//            cell.stackVIew.addArrangedSubview(image)
        }
        
        return cell
    }

}




