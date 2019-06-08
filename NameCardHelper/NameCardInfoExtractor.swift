import Contacts
import SwiftyUtils

struct ExtractedInfo {
    let contact: CNMutableContact
    let remainingText: [String]
}

extension NameCard {
    func extractInfo() -> ExtractedInfo {
        let types: NSTextCheckingResult.CheckingType = [.link, .address, .phoneNumber]
        let detector = try! NSDataDetector(types: types.rawValue)
        let contact = CNMutableContact()
        var remainingText = ""
        for text in self.blocks.map({ $0.text }) {
            let textCopy = NSMutableString(string: text)
            var ranges = [NSRange]()
            detector.enumerateMatches(in: text, options: [], range: NSRange(location: 0, length: text.count)) { (result, _, _) in
                extractInfo(in: result, to: contact)
                ranges.insert(result!.range, at: 0)
            }
            for range in ranges {
                textCopy.replaceCharacters(in: range, with: "")
            }
            remainingText += "\n" + (textCopy as String)
        }
        return ExtractedInfo(contact: contact, remainingText: remainingText.split(separator: "\n").map(String.init).filter { String($0).trimmed() != "" })
    }
    
    fileprivate func extractInfo(in result: NSTextCheckingResult?, to contact: CNMutableContact) {
        if let link = result?.url {
            if link.scheme == "mailto" {
                contact.emailAddresses.append(CNLabeledValue(label: "Work", value: (link as NSURL).resourceSpecifier! as NSString))
            } else {
                contact.urlAddresses.append(CNLabeledValue(label: "Work", value: link.absoluteString as NSString))
            }
        }
        if let phone = result?.phoneNumber {
            contact.phoneNumbers.append(CNLabeledValue(label: "Unlabeled", value: CNPhoneNumber(stringValue: phone)))
        }
        if let address = result?.addressComponents {
            let cnAddress = CNMutablePostalAddress()
            cnAddress.city = address[.city] ?? ""
            cnAddress.country = address[.country] ?? ""
            cnAddress.street = address[.street] ?? ""
            cnAddress.state = address[.state] ?? ""
            cnAddress.postalCode = address[.zip] ?? ""
            contact.postalAddresses.append(CNLabeledValue(label: "Company", value: cnAddress))
        }
    }
}
