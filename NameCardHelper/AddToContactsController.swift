import UIKit
import Eureka
import SuggestionRow
import SplitRow
import ViewRow
import FloatLabelRow
import PostalAddressRow
import Contacts
import ContactsUI

class AddToContactsController: FormViewController {
    var nameCard: NameCard!
    var extractedInfo: ExtractedInfo!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form +++ Section()
        <<< SuggestionAccessoryRow<String>(tagFullName) {
            row in
            row.title = "Full Name"
            row.filterFunction = filterFunction
        }
        
        <<< SuggestionAccessoryRow<String>(tagCompany) {
            row in
            row.title = "Company"
            row.filterFunction = filterFunction
        }
        
        <<< SuggestionAccessoryRow<String>(tagJobTitle) {
            row in
            row.title = "Job Title"
            row.filterFunction = filterFunction
        }

        form +++ Section("preview")
            
            <<< ViewRow<UIView>(tagPreview) {
                row in
                
                }.cellSetup({ [weak self] (cell, row) in
                    cell.view = self?.nameCard.createCardView(withWidth: cell.width - cell.viewLeftMargin - cell.viewRightMargin)
                    cell.backgroundColor = .black
                })
        
    func filterFunction(text: String) -> [String] {
        return self.extractedInfo.remainingText.filter { text == "" || $0.contains(text) }
    }
    }
}
