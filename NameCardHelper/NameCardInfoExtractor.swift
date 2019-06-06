import Contacts
import SwiftyUtils

struct ExtractedInfo {
    let contact: CNMutableContact
    let remainingText: [String]
}

extension NameCard {
    func extractInfo() -> ExtractedInfo {
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
