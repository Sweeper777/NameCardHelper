import UIKit

fileprivate func shouldContinueToEnlarge(targetSize: CGSize, currentSize: CGSize) -> Bool {
    return targetSize.height > currentSize.height && targetSize.width > currentSize.width
}

func fontSizeThatFits(size: CGSize, text: NSString, font: UIFont) -> CGFloat {
    var fontToTest = font.withSize(0)
    var currentSize = text.size(withAttributes: [NSAttributedString.Key.font: fontToTest])
    var fontSize = CGFloat(0.2)
    while shouldContinueToEnlarge(targetSize: size, currentSize: currentSize) {
        fontToTest = fontToTest.withSize(fontSize)
        currentSize = text.size(withAttributes: [NSAttributedString.Key.font: fontToTest])
        fontSize += 0.2
    }
    return fontSize - 0.2
}

extension UILabel {
    func updateFontSizeToFit(size: CGSize, multiplier: CGFloat = 0.9) {
        let fontSize = fontSizeThatFits(size: size, text: (text ?? "a") as NSString, font: font) * multiplier
        print(fontSize)
        font = font.withSize(fontSize)
    }
    
    func updateFontSizeToFit() {
        updateFontSizeToFit(size: bounds.size)
    }
}
