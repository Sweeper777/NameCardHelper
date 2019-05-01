import UIKit

extension NameCard {
    func createCardView(withWidth width: CGFloat) -> UIView {
        let cardView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: width / nameCardWHRatio))
        populateView(cardView)
        cardView.layer.cornerRadius = 10
        return cardView
    }
    
    func populateView(_ cardView: UIView) {
        let padding = 5.f
        let scaleX: CGFloat
        let scaleY: CGFloat
        let offsetX: CGFloat
        let offsetY: CGFloat
        if self.aspectRatio.f > cardView.width / cardView.height {
            scaleX = cardView.width
            scaleY = scaleX / self.aspectRatio.f
            offsetX = 0
            offsetY = (cardView.height - scaleY) / 2
        } else {
            scaleY = cardView.height
            scaleX = scaleY * self.aspectRatio.f
            offsetY = 0
            offsetX = (cardView.width - scaleX) / 2
        }
        for block in self.blocks {
            var newFrame = block.rect.applying(CGAffineTransform(scaleX: scaleX - padding, y: scaleY - padding))
            newFrame = newFrame.with(x: newFrame.x + offsetX)
                .with(y: newFrame.y + offsetY)
            let label = UITextView(frame: newFrame)
            label.backgroundColor = .clear
            label.text = block.text
            label.isScrollEnabled = false
            label.isEditable = false
            label.textContainer.lineFragmentPadding = 0
            label.textContainerInset = .zero
            label.dataDetectorTypes = [.phoneNumber, .link, .address]
            label.textAlignment = .left
            label.font = UIFont(name: "Menlo", size: fontSize(forString: block.text, toFit: label.bounds.size))
            cardView.addSubview(label)
        }
        
        cardView.backgroundColor = self.uiColor
    }
    
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
