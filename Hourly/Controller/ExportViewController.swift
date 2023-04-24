//
//  ExportViewController.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-12.
//

import UIKit
import CoreData

class ExportViewController: UIViewController {
    
    
    @IBOutlet weak var clientTextField: ClientSearchTextField!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    
    private var selectedClient: ClientItem?
    
    private var selectedClientID: NSManagedObjectID? {
        didSet {
            if let id = selectedClientID {
                do {
                    selectedClient = try databaseContext.existingObject(with: id) as? ClientItem
                } catch {
                    fatalError(error.localizedDescription)
                }
            } else {
                if selectedClient != nil {
                    selectedClient = nil
                }
            }
        }
    }
    
    private let databaseContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        clientTextField.searchDelegate = self
    }
    
    
    @IBAction func exportButtonPressed(_ sender: UIButton) {
        
    }
    
    
}


//MARK: - ClientSearchDelegate
extension ExportViewController: ClientSearchDelegate {
    func selectedExistingClient(_ clientSearchTextField: ClientSearchTextField, clientID: NSManagedObjectID?) {
        self.selectedClientID = clientID
    }
}
