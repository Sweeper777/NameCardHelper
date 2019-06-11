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
        
    func filterFunction(text: String) -> [String] {
        return self.extractedInfo.remainingText.filter { text == "" || $0.contains(text) }
    }
    }
}
