//
//  ClientSearchTextField.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-17.
//

import UIKit
import CoreData

protocol ClientSearchDelegate: AnyObject {
    func selectedExistingClient(_ clientSearchTextField: ClientSearchTextField, clientID: NSManagedObjectID?)
    func didEndEditing(_ clientSearchTextField: ClientSearchTextField)
}
extension ClientSearchDelegate {
    func didEndEditing(_ clientSearchTextField: ClientSearchTextField) {}
}
class ClientSearchTextField: FloatingLabelTextField {
    // MARK: - Variables
    var clientArray: Array<ClientItem> = []
    var tableView: UITableView?
    private let coreDataService = CoreDataService()
    weak var searchDelegate: ClientSearchDelegate?
    
    open override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        tableView?.removeFromSuperview()
    }
    
    override open func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        // Add targets to notify function when editing changes or finishes.
        self.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        self.addTarget(self, action: #selector(textFieldDidEndEditing), for: .editingDidEnd)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        buildSearchTableView()
    }
    
    @objc open func textFieldDidChange(){
        // If text changes set the selected client to nil.
        self.searchDelegate?.selectedExistingClient(self, clientID: nil)
        filter()
        updateSearchTableView()
        tableView?.isHidden = false
    }
    
    @objc open func textFieldDidEndEditing() {
        searchDelegate?.didEndEditing(self)
    }
    
    // MARK : Filtering methods
    fileprivate func filter() {
        let predicate = NSPredicate(format: "companyName CONTAINS[cd] %@", self.text!)
        let request : NSFetchRequest<ClientItem> = ClientItem.fetchRequest()
        request.predicate = predicate
        
        // Loading the data into the dataList
        coreDataService.getClients(withRequest: request)
    }
    
    func buildSearchTableView() {
        if let tableView = tableView {
            coreDataService.delegate = self
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: K.Cell.clientSearchCell)
            tableView.delegate = self
            tableView.dataSource = self
            self.window?.addSubview(tableView)
        } else {
            tableView = UITableView(frame: CGRect.zero)
        }
        updateSearchTableView()
    }
    
    func updateSearchTableView() {
        if let tableView = tableView {
            superview?.bringSubviewToFront(tableView)
            var tableHeight: CGFloat = 0
            tableHeight = tableView.contentSize.height
            // Set a bottom margin of 10p.
            if tableHeight < tableView.contentSize.height {
                tableHeight -= 10
            }
            // Set tableView frame.
            var tableViewFrame = CGRect(x: 0, y: 0, width: frame.size.width - 4, height: tableHeight)
            tableViewFrame.origin = self.convert(tableViewFrame.origin, to: nil)
            tableViewFrame.origin.x += 2
            tableViewFrame.origin.y += frame.size.height + 2
            UIView.animate(withDuration: 0.2, animations: { [weak self] in
                self?.tableView?.frame = tableViewFrame
            })
            //Setting tableView style.
            tableView.layer.masksToBounds = true
            tableView.separatorInset = UIEdgeInsets.zero
            tableView.layer.cornerRadius = 5.0
            tableView.separatorColor = UIColor.lightGray
            tableView.backgroundColor = UIColor.white.withAlphaComponent(0.4)
            if self.isFirstResponder {
                superview?.bringSubviewToFront(self)
            }
            DispatchQueue.main.async { tableView.reloadData() }
        }
    }
}

// MARK: - UITableViewDelegate
extension ClientSearchTextField: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // After selecting client dismiss keyboard and hide table view.
        self.text = clientArray[indexPath.row].companyName
        self.searchDelegate?.selectedExistingClient(self, clientID: clientArray[indexPath.row].objectID)
        tableView.isHidden = true
        self.endEditing(true)
    }
}

// MARK: - UITableViewDataSource
extension ClientSearchTextField: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clientArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Cell.clientSearchCell, for: indexPath) as UITableViewCell
        cell.backgroundColor = .white
        cell.textLabel?.text = clientArray[indexPath.row].companyName
        return cell
    }
}

// MARK: - CoreDataServiceDelegate
extension ClientSearchTextField: CoreDataServiceDelegate {
    func loadedClients(_ coreDataService: CoreDataService, clientItems: Array<ClientItem>) {
        clientArray = clientItems
        DispatchQueue.main.async { self.tableView?.reloadData() }
    }
}
