import UIKit
import CircleMenu
import SCLAlertView
import HFCardCollectionViewLayout

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
        }
    }
    
    func deleteCard(atIndex index: Int) {
        let card = shownCards[index]
        (cardCollectionView.collectionViewLayout as? HFCardCollectionViewLayout)?.unrevealCard(completion: {
            [weak self] in
            self?.shownCards.remove(at: index)
            self?.cardCollectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
            do {
                try RealmWrapper.shared.realm.write {
                    RealmWrapper.shared.realm.delete(card)
                }
            } catch let error {
                print(error)
            }
        })
    }
}