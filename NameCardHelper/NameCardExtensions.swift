import UIKit

extension NameCard {
    private func sizeForUnitCharacter() -> CGSize {
        let unitChar = NSAttributedString(string: "o", attributes: [.font: UIFont(name: "Menlo", size: 1)!])
        return unitChar.size()
    }
    
    private func fontSize(forString string: String, toFit size: CGSize) -> CGFloat {
        guard let longestLineCharCount = string.split(separator: "\n").map({ $0.count }).max() else { return 0 }
        let numberOfLines = string.filter { $0 == "\n" }.count + 1
        let unitSize = sizeForUnitCharacter()
        let eachCharacterMaxWidth = size.width / longestLineCharCount.f
        let eachCharacterMaxHeight = size.height / numberOfLines.f
        return min(eachCharacterMaxWidth / unitSize.width, eachCharacterMaxHeight / unitSize.height)
    }
}
