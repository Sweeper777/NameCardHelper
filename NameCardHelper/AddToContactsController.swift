import UIKit
import Eureka
import SuggestionRow
import SplitRow
import ViewRow
import FloatLabelRow
import PostalAddressRow
import Contacts
import ContactsUI

class AddToContactsController: FormViewController {
    var nameCard: NameCard!
    var extractedInfo: ExtractedInfo!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form +++ Section()
        <<< SuggestionAccessoryRow<String>(tagFullName) {
            row in
            row.title = "Full Name"
            row.filterFunction = filterFunction
        }
        
        <<< SuggestionAccessoryRow<String>(tagCompany) {
            row in
            row.title = "Company"
            row.filterFunction = filterFunction
        }
        
        <<< SuggestionAccessoryRow<String>(tagJobTitle) {
            row in
            row.title = "Job Title"
            row.filterFunction = filterFunction
        }

        form +++ Section("preview")
            
            <<< ViewRow<UIView>(tagPreview) {
                row in
                
                }.cellSetup({ [weak self] (cell, row) in
                    cell.view = self?.nameCard.createCardView(withWidth: cell.width - cell.viewLeftMargin - cell.viewRightMargin)
                    cell.backgroundColor = .black
                })
        
        let phoneSection = Section("phone/fax")
        
        for (i, phoneNumber) in extractedInfo.contact.phoneNumbers.enumerated() {
            phoneSection <<< SplitRow<TextFloatLabelRow, TextRow>(tagPhone + "\(i)") {
                row in
                row.rowLeft = TextFloatLabelRow() {
                    rowLeft in
                    rowLeft.cell.textField.autocapitalizationType = .none
                    rowLeft.title = "Type"
                    rowLeft.value = phoneNumber.label
                }
                row.rowRight = TextRow() {
                    rowRight in
                    rowRight.value = phoneNumber.value.stringValue
                }
                row.rowLeftPercentage = 0.4
            }
        }
        
        form +++ phoneSection
        
        let addressSection = Section("address")
        for (i, address) in extractedInfo.contact.postalAddresses.enumerated() {
            addressSection <<< PostalAddressRow() {
                row in
                row.tag = tagAddress + "\(i)"
                row.streetPlaceholder = "Street"
                row.statePlaceholder = "State"
                row.cityPlaceholder = "City"
                row.countryPlaceholder = "Country"
                row.postalCodePlaceholder = "Zip code"
                row.value = PostalAddress(
                    street: address.value.street,
                    state: address.value.state,
                    postalCode: address.value.postalCode,
                    city: address.value.city,
                    country: address.value.country)
            }
        }
        
        form +++ addressSection
        
        let emailSection = Section("email")
        for (i, email) in extractedInfo.contact.emailAddresses.enumerated() {
            emailSection <<< SplitRow<TextFloatLabelRow, TextRow>(tagEmail + "\(i)") {
                row in
                row.rowLeft = TextFloatLabelRow() {
                    rowLeft in
                    rowLeft.cell.textField.autocapitalizationType = .none
                    rowLeft.title = "Type"
                    rowLeft.value = email.label
                }
                row.rowRight = TextRow() {
                    rowRight in
                    rowRight.value = email.value as String
                }
                row.rowLeftPercentage = 0.4
            }
        }
        
        form +++ emailSection
        
        let urlSection = Section("website")
        for (i, url) in extractedInfo.contact.urlAddresses.enumerated() {
            urlSection <<< SplitRow<TextFloatLabelRow, TextRow>(tagURL + "\(i)") {
                row in
                row.rowLeft = TextFloatLabelRow() {
                    rowLeft in
                    rowLeft.cell.textField.autocapitalizationType = .none
                    rowLeft.title = "Type"
                    rowLeft.value = url.label
                }
                row.rowRight = TextRow() {
                    rowRight in
                    rowRight.value = url.value as String
                }
                row.rowLeftPercentage = 0.4
            }
        }
        
        form +++ urlSection
    }
    
    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func next() {
        let values = form.values()
        if let name = values[tagFullName] as? String {
            let formatter = PersonNameComponentsFormatter()
            let components = formatter.personNameComponents(from: name)
            extractedInfo.contact.namePrefix = components?.namePrefix ?? ""
            extractedInfo.contact.nameSuffix = components?.nameSuffix ?? ""
            extractedInfo.contact.givenName = components?.givenName ?? ""
            extractedInfo.contact.familyName = components?.familyName ?? ""
            extractedInfo.contact.middleName = components?.middleName ?? ""
        }
        if let company = values[tagCompany] as? String {
            extractedInfo.contact.organizationName = company
        }
        if let jobTitle = values[tagJobTitle] as? String {
            extractedInfo.contact.jobTitle = jobTitle
        }
        for i in 0..<extractedInfo.contact.phoneNumbers.count {
            if let splitValue = values[tagPhone + "\(i)"] as? SplitRowValue<String, String> {
                extractedInfo.contact.phoneNumbers[i] = CNLabeledValue(label: splitValue.left ?? "", value: CNPhoneNumber(stringValue: splitValue.right ?? ""))
            }
        }
        for i in 0..<extractedInfo.contact.postalAddresses.count {
            if let address = values[tagAddress + "\(i)"] as? PostalAddress {
                let cnAddress = CNMutablePostalAddress()
                cnAddress.city = address.city ?? ""
                cnAddress.country = address.country ?? ""
                cnAddress.state = address.country ?? ""
                cnAddress.street = address.street ?? ""
                cnAddress.postalCode = address.postalCode ?? ""
                extractedInfo.contact.postalAddresses[i] = CNLabeledValue(label: "Company", value: cnAddress as CNPostalAddress)
            }
        }
        for i in 0..<extractedInfo.contact.emailAddresses.count {
            if let splitValue = values[tagEmail + "\(i)"] as? SplitRowValue<String, String> {
                extractedInfo.contact.emailAddresses[i] = CNLabeledValue(label: splitValue.left ?? "", value: (splitValue.right ?? "") as NSString)
            }
        }
        for i in 0..<extractedInfo.contact.urlAddresses.count {
            if let splitValue = values[tagURL + "\(i)"] as? SplitRowValue<String, String> {
                extractedInfo.contact.urlAddresses[i] = CNLabeledValue(label: splitValue.left ?? "", value: (splitValue.right ?? "") as NSString)
            }
        }
        
        let contact = extractedInfo.contact
        let contactStore = CNContactStore()
        let vc = CNContactViewController(forUnknownContact: contact)
        vc.contactStore = contactStore
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func filterFunction(text: String) -> [String] {
        return self.extractedInfo.remainingText.filter { text == "" || $0.contains(text) }
    }
}

extension AddToContactsController : CNContactViewControllerDelegate {
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
        if contact != nil {
            try? RealmWrapper.shared.realm.write {
                [weak self] in
                self?.nameCard.addedToContacts = true
            }
            
            self.dismiss(animated: true, completion: nil)
        }
    }
}
