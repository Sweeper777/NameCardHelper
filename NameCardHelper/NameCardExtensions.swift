import UIKit

extension NameCard {
    private func sizeForUnitCharacter() -> CGSize {
        let unitChar = NSAttributedString(string: "o", attributes: [.font: UIFont(name: "Menlo", size: 1)!])
        return unitChar.size()
    }
    
}
