//
//  ClientSearchTextField.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-17.
//

import UIKit
import CoreData

class ClientSearchTextField: UITextField {


    var clientArray: Array<ClientItem> = []
    var tableView: UITableView?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    open override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        tableView?.removeFromSuperview()
    }
    
    override open func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        self.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        self.addTarget(self, action: #selector(textFieldDidBeginEditing), for: .editingDidBegin)
        self.addTarget(self, action: #selector(textFieldDidEndEditing), for: .editingDidEnd)
        self.addTarget(self, action: #selector(textFieldDidEndEditingOnExit), for: .editingDidEndOnExit)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        buildSearchTableView()
    }
    
    @objc open func textFieldDidChange(){
        filter()
        updateSearchTableView()
        tableView?.isHidden = false
    }
    
    @objc open func textFieldDidBeginEditing() {
        updateSearchTableView()
        tableView?.isHidden = false
    }
        
    @objc open func textFieldDidEndEditing() {
    }
        
    @objc open func textFieldDidEndEditingOnExit() {
    }
    
    func loadItems(withRequest request : NSFetchRequest<ClientItem>) {
        do {
            self.clientArray = try context.fetch(request)
            
        } catch {
            print("Error while fetching data: \(error)")
        }
    }
    
    // MARK : Filtering methods
    fileprivate func filter() {
        let predicate = NSPredicate(format: "companyName CONTAINS[cd] %@", self.text!)
        let request : NSFetchRequest<ClientItem> = ClientItem.fetchRequest()
        request.predicate = predicate

        //Loading the data into the dataList
        loadItems(withRequest : request)
        
        tableView?.reloadData()
     }
    
    func buildSearchTableView() {
        if let tableView = tableView {
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
             
             // Set a bottom margin of 10p
             if tableHeight < tableView.contentSize.height {
                 tableHeight -= 10
             }
             
             // Set tableView frame
             var tableViewFrame = CGRect(x: 0, y: 0, width: frame.size.width - 4, height: tableHeight)
             tableViewFrame.origin = self.convert(tableViewFrame.origin, to: nil)
             tableViewFrame.origin.x += 2
             tableViewFrame.origin.y += frame.size.height + 2
             UIView.animate(withDuration: 0.2, animations: { [weak self] in
                 self?.tableView?.frame = tableViewFrame
             })
             
             //Setting tableView style
             tableView.layer.masksToBounds = true
             tableView.separatorInset = UIEdgeInsets.zero
             tableView.layer.cornerRadius = 5.0
             tableView.separatorColor = UIColor.lightGray
             tableView.backgroundColor = UIColor.white.withAlphaComponent(0.4)
             
             if self.isFirstResponder {
                 superview?.bringSubviewToFront(self)
             }
             
             tableView.reloadData()
         }
     }
}

//MARK: - UITableViewDelegate

extension ClientSearchTextField: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.text = clientArray[indexPath.row].companyName
        tableView.isHidden = true
        self.endEditing(true)
    }
}

//MARK: - UITableViewDataSource

extension ClientSearchTextField: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(clientArray.count)
        return clientArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Cell.clientSearchCell, for: indexPath) as UITableViewCell
        cell.backgroundColor = .clear
        cell.textLabel?.text = clientArray[indexPath.row].companyName
        return cell
    }
}
