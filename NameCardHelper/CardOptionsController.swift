import UIKit
import Eureka
import ViewRow
import ColorPickerRow

class CardOptionsController: FormViewController {
    var nameCard: NameCard!
    var image: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form +++ SwitchRow(tagSaveOriginalImage) {
            row in
            row.title = "Save Original Image"
            row.value = false
        }
        
    }
}
