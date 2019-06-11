import UIKit
import Eureka
import SuggestionRow
import SplitRow
import ViewRow

class AddToContactsController: FormViewController {
    var nameCard: NameCard!
    var extractedInfo: ExtractedInfo!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    func filterFunction(text: String) -> [String] {
        return self.extractedInfo.remainingText.filter { text == "" || $0.contains(text) }
    }
    }
}
