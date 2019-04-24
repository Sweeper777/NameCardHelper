//
// Copyright (c) David Coufal 2015
// davidcoufal.com
// Released for general use under an MIT license: http://opensource.org/licenses/MIT
//

import UIKit

/**
 This function takes a font and returns a new font (if required) that can be used to fit the given String into the given CGRect.
 
 Only the pointSize of the font is modified.
 
 @param font: The font to start with.
 @param toRect: The CGRect to fit the string into using the font
 @param forString: The string to be fitted.
 @param withMaxFontSize: The maximum pointSize to be used.
 @param withMinFontSize: The minimum pointSize to be used.
 @param withFontSizeIncrement: The amount to increment the font pointSize by during calculations. Smaller values give a more accurate result, but take longer to calculate.
 @param andStringDrawingOptions: The `NSStringDrawingOptions` to be used in the call to String.boundingRect to calculate fits.
 
 @return A new UIFont (if needed, if no calculations can be performed the same font is returned) that will fit the String to the CGRect
 */
public func resize(
    font: UIFont,
    toRect rect: CGRect,
    forString text: String?,
    withMaxFontSize maxFontSizeIn: CGFloat,
    withMinFontSize minFontSize: CGFloat,
    withFontSizeIncrement fontSizeIncrement: CGFloat = 1.0,
    andStringDrawingOptions stringDrawingOptions: NSStringDrawingOptions = .usesLineFragmentOrigin ) -> UIFont
{
    guard maxFontSizeIn > minFontSize else {
        assertionFailure("maxFontSize should be larger than minFontSize")
        return font
    }
    guard let text = text else {
        return font
    }
    
    var maxFontSize = maxFontSizeIn
    
    let words = text.components(separatedBy: CharacterSet.whitespacesAndNewlines)
    
    // calculate max font size based on each word
    for word in words {
        maxFontSize = getMaxFontSize(forWord: word,
                                     forWidth: rect.width,
                                     usingFont: font,
                                     withMaxFontSize: maxFontSize,
                                     withMinFontSize: minFontSize,
                                     withFontSizeIncrement: fontSizeIncrement)
    }
    
    // calculate what the font size should be based on entire phrase
    var tempfont = font.withSize(maxFontSize)
    
    var currentFontSize = maxFontSize
    while (currentFontSize > minFontSize) {
        tempfont = font.withSize(currentFontSize)
        
        let constraintSize = CGSize(width: rect.size.width, height: CGFloat.greatestFiniteMagnitude)
        
        let labelSize = text.boundingRect(
            with: constraintSize,
            options: stringDrawingOptions,
            attributes: [ NSAttributedString.Key.font : tempfont ],
            context: nil)
        
        if (labelSize.height <= rect.height) {
            break
        }
        currentFontSize -= fontSizeIncrement
    }
    
    return tempfont;
}

internal func getMaxFontSize(
    forWord word: String,
    forWidth width: CGFloat,
    usingFont font: UIFont,
    withMaxFontSize maxFontSize: CGFloat,
    withMinFontSize minFontSize: CGFloat,
    withFontSizeIncrement fontSizeIncrement: CGFloat) -> CGFloat
{
    var currentFontSize: CGFloat = maxFontSize
    while (currentFontSize > minFontSize) {
        let tempfont = font.withSize(currentFontSize)
        let labelSize = word.size(withAttributes: [NSAttributedString.Key.font: tempfont])
        if (labelSize.width < width) {
            return currentFontSize
        }
        currentFontSize -= fontSizeIncrement
    }
    return minFontSize
}
