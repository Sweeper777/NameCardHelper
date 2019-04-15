//
//  Created by Tom Baranes on 16/11/2016.
//  Copyright © 2016 Tom Baranes. All rights reserved.
//

import UIKit

// MARK: - Text style

extension UILabel {

    public func setLineHeight(_ lineHeight: CGFloat) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1.0
        paragraphStyle.lineHeightMultiple = lineHeight
        paragraphStyle.alignment = textAlignment
        paragraphStyle.lineBreakMode = lineBreakMode

        let attrString = NSMutableAttributedString(string: text!)
        attrString.addAttribute(NSAttributedString.Key.font, value: font, range: NSRange(location: 0, length: attrString.length))
        attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attrString.length))
        attributedText = attrString
    }

}

// MARK: - Text

extension UILabel {

    public func setText(_ text: String, truncatedText: String) {
        var text = text
        self.text = text
        while isTruncated() && text.isNotEmpty {
            text = String(text.dropLast())
            self.text = text + truncatedText
        }
    }

}

// MARK: - Misc

extension UILabel {

    public func isTruncated() -> Bool {
        guard let string = text else {
            return false
        }

        let rectSize = CGSize(width: self.width, height: .greatestFiniteMagnitude)
        let size: CGSize = (string as NSString).boundingRect(with: rectSize,
                                                             options: .usesLineFragmentOrigin,
                                                             attributes: [NSAttributedString.Key.font: font],
                                                             context: nil).size
        return (size.height > self.bounds.size.height)
    }

}
