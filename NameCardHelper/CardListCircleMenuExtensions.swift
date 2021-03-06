import UIKit
import CircleMenu
import SCLAlertView
import HFCardCollectionViewLayout
import Contacts
import ContactsUI

extension CardListController : CircleMenuDelegate {
    func circleMenu(_ circleMenu: CircleMenu, willDisplay button: UIButton, atIndex: Int) {
        /*
         0. delete
         1. edit
         2. move to
         3. zoom
         4. add to contact
         */
        button.backgroundColor = circleMenuItems[atIndex].color
        
        button.setImage(UIImage(named: circleMenuItems[atIndex].icon), for: .normal)
        
        let highlightedImage = UIImage(named: circleMenuItems[atIndex].icon)?.withRenderingMode(.alwaysTemplate)
        button.setImage(highlightedImage, for: .highlighted)
        button.tintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
    }
    
    func circleMenu(_ circleMenu: CircleMenu, buttonDidSelected button: UIButton, atIndex: Int) {
        guard let selectedCard = self.selectedCard else {
            let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
            alert.addButton("OK", action: {})
            alert.showWarning("Please select a card first!", subTitle: "")
            return
        }
        
        if atIndex == 3 {
            performSegue(withIdentifier: "zoomIn", sender: selectedCard)
        } else if atIndex == 0 {
            let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
            alert.addButton("Yes", action: { [weak self] in self?.deleteCard(atIndex: (self?.selectedCardIndex)!) })
            alert.addButton("No", action: {})
            alert.showWarning("Confirm", subTitle: "Are you sure you want to delete this card?")
        } else if atIndex == 2 {
            performSegue(withIdentifier: "showMoveToGroup", sender: selectedCard.group.first ?? .ungrouped)
        } else if atIndex == 4 {
            if selectedCard.addedToContacts {
                let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
                alert.addButton("Yes", action: addToContact)
                alert.addButton("No", action: {})
                alert.showWarning("Confirm", subTitle: "This card has already been added to contact before. Do you want to add it again?")
            } else {
                addToContact()
            }
        } else if atIndex == 1 {
            let layout = self.cardCollectionView.collectionViewLayout as! HFCardCollectionViewLayout
            let container = UIView()
            container.backgroundColor = selectedCard.uiColor
            container.tag = containerViewTag
            let textView = UITextView()
            container.addSubview(textView)
            textView.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(16)
                make.right.equalToSuperview().offset(-16)
                make.top.equalToSuperview().offset(16)
                make.bottom.equalToSuperview().offset(-70)
            }
            textView.backgroundColor = .clear
            textView.font = UIFont.systemFont(ofSize: 16)
            textView.text = selectedCard.backsideText
            
            let button = UIButton(type: .system)
            button.setTitle("Done", for: .normal)
            button.addTarget(self, action: #selector(doneEditingCardBack), for: .touchUpInside)
            container.addSubview(button)
            button.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.top.equalTo(textView.snp.bottom).offset(8)
            }
            
            layout.flipRevealedCard(toView: container)
        }
    }
    
    func addToContact() {
        guard let selectedCard = self.selectedCard else { return }
        let extractedInfo = selectedCard.extractInfo()
        performSegue(withIdentifier: "showAddToContacts", sender: (selectedCard, extractedInfo))
    }
    
    @objc func doneEditingCardBack() {
        if let layout = cardCollectionView.collectionViewLayout as? HFCardCollectionViewLayout,
            let selectedCard = self.selectedCard,
            let cardView = cardCollectionView.cellForItem(at: IndexPath(item: layout.revealedIndex, section: 0)),
            let textView = cardView.viewWithTag(containerViewTag)?.subviews.first as? UITextView {
            try? RealmWrapper.shared.realm.write {
                selectedCard.backsideText = textView.text
            }
            layout.flipRevealedCardBack()
        }
    }
    
    func deleteCard(atIndex index: Int) {
        let card = shownCards[index]
        (cardCollectionView.collectionViewLayout as? HFCardCollectionViewLayout)?.unrevealCard(completion: {
            [weak self] in
            self?.shownCards.remove(at: index)
            do {
                try RealmWrapper.shared.realm.write {
                    RealmWrapper.shared.realm.delete(card)
                }
            } catch let error {
                print(error)
            }
            if self?.shownCards.count == 0 {
                self?.cardCollectionView.reloadData()
            } else {
                self?.cardCollectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
            }
        })
    }
}

extension CardListController : MoveToGroupControllerDelegate {
    func didSelectGroup(moveToGroupController: MoveToGroupController, group: Group?) {
        guard let selectedCard = self.selectedCard else { return }
        let index = self.selectedCardIndex!
        guard group != selectedCard.group.first else { return }
        (cardCollectionView.collectionViewLayout as? HFCardCollectionViewLayout)?.unrevealCard(completion: {
            [weak self] in
            guard let `self` = self else { return }
            self.shownCards.remove(at: index)
            do {
                try RealmWrapper.shared.realm.write {
                    if let originalGroup = selectedCard.group.first {
                        originalGroup.nameCards.remove(at: originalGroup.nameCards.index(of: selectedCard)!)
                    }
                    group?.nameCards.append(selectedCard)
                }
            } catch let error {
                print(error)
            }
            if self.shownCards.count == 0 {
                self.cardCollectionView.reloadData()
            } else {
                self.cardCollectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
            }
        })
    }
}
