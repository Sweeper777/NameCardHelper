import UIKit
import SwiftyUtils
import HFCardCollectionViewLayout
import CircleMenu
import SnapKit

class CardListController: UIViewController {

    @IBOutlet var groupCollectionView: UICollectionView!
    @IBOutlet var cardCollectionView: UICollectionView!
    var circleMenu: CircleMenu!
    
    let circleMenuItems: [(icon: String, color: UIColor)] = [
        ("delete", UIColor(hex: "a8383b")),
        ("edit", UIColor(hex: "aa9239")),
        ("move", UIColor(hex: "328a2e")),
        ("zoom in", UIColor(hex: "3b3176")),
        ("addContact", UIColor(hex: "246b61")),
        ]
    
    let groups = ["Foo", "Bar", "Baz", "Long Group Name", "Others"]
    let groupLabelFontSize = 17.f
    
    var shownCards: [NameCard]!
    
    var selectedCard: NameCard? {
        if shownCards.count == 1 {
            return shownCards.first
        } else {
            let index = (cardCollectionView.collectionViewLayout as! HFCardCollectionViewLayout).revealedIndex
            if index != -1 {
                return shownCards[index]
            } else {
                return nil
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shownCards = Array(RealmWrapper.shared.cards)
        cardCollectionView.dataSource = self
        cardCollectionView.delegate = self
        cardCollectionView.backgroundView = UIView()
        
        circleMenu = CircleMenu(frame: CGRect(x: 0, y: 0, width: 64, height: 64), normalIcon: "menu", selectedIcon: "close")
        circleMenu.buttonsCount = 5
        circleMenu.delegate = self
        cardCollectionView.backgroundView!.addSubview(circleMenu)
        circleMenu.startAngle = -90
        circleMenu.endAngle = 90
        circleMenu.layer.cornerRadius = 20
//        circleMenu.layer.borderWidth = 2
        circleMenu.backgroundColor = UIColor(hex: "3a7b3b")
        circleMenu.duration = 0.5
        circleMenu.snp.makeConstraints { (make) in
            make.width.equalTo(40)
            make.height.equalTo(40)
            make.centerX.equalToSuperview()
            make.top.equalTo(cardCollectionView.backgroundView!.snp.bottom).dividedBy(1.25)
        }
        circleMenu.isHidden = true
        
        let layout = cardCollectionView.collectionViewLayout as! HFCardCollectionViewLayout
        layout.cardMaximumHeight = UIScreen.width / nameCardWHRatio
        layout.cardHeadHeight = UIScreen.width / nameCardWHRatio + 10
        layout.scrollStopCardsAtTop = false
        
        groupCollectionView.allowsMultipleSelection = false
        groupCollectionView.dataSource = self
        groupCollectionView.delegate = self
    }

    @IBAction func newPress() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            actionSheet.addAction(UIAlertAction(title: "New Card (Photo Library)", style: .default, handler: {
                [weak self] _ in
                self?.newCard(sourceType: .photoLibrary)
            }))
        }
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            actionSheet.addAction(UIAlertAction(title: "New Card (Camera)", style: .default, handler: {
                [weak self] _ in
                self?.newCard(sourceType: .camera)
            }))
        }
        actionSheet.addAction(UIAlertAction(title: "New Group", style: .default, handler: {
            [weak self] _ in
            self?.newGroup()
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func newCard(sourceType: UIImagePickerController.SourceType) {
        let imagePicker = MyImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func newGroup() {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = (segue.destination as? UINavigationController)?.topViewController as? PreviewController,
            let image = sender as? UIImage {
            vc.imageToProcess = image
        } else if let vc = (segue.destination as? UINavigationController)?.topViewController as? ZoomViewController,
            let card = sender as? NameCard {
            vc.card = card
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    @IBAction func unwindFromNewCard(segue: UIStoryboardSegue) {
        shownCards = Array(RealmWrapper.shared.cards)
        cardCollectionView.reloadData()
    }
}

extension CardListController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) { [ weak self] in
            if let image = info[.originalImage] as? UIImage {
                self?.performSegue(withIdentifier: "showPreview", sender: image)
            }
        }
    }
}

// MARK: Collection View Delegate and Data Source

extension CardListController : UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == cardCollectionView {
            return cardCollectionView(collectionView, numberOfItemsInSection: section)
        } else if collectionView == groupCollectionView {
            return groupCollectionView(collectionView, numberOfItemsInSection: section)
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == cardCollectionView {
            return cardCollectionView(collectionView, cellForItemAt: indexPath)
        } else if collectionView == groupCollectionView {
            return groupCollectionView(collectionView, cellForItemAt: indexPath)
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == cardCollectionView {
            cardCollectionView(collectionView, didSelectItemAt: indexPath)
        }
    }
}

// MARK: Card Collection View Delegate and Data Source

extension CardListController {
    func cardCollectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shownCards.count
    }
    
    func cardCollectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! HFCardCollectionViewCell
        let model = shownCards[indexPath.item]
        cell.subviews.filter { $0 != cell.contentView }.forEach { $0.removeFromSuperview() }
        model.populateView(cell)
        cell.subviews.forEach { $0.isUserInteractionEnabled = false }
        return cell
    }
    
    func cardCollectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        (collectionView.collectionViewLayout as! HFCardCollectionViewLayout).revealCardAt(index: indexPath.item)
    }
}

extension CardListController : HFCardCollectionViewLayoutDelegate {
    func cardCollectionViewLayout(_ collectionViewLayout: HFCardCollectionViewLayout, didRevealCardAtIndex index: Int) {
        cardCollectionView.cellForItem(at: IndexPath(item: index, section: 0))!.subviews.forEach { $0.isUserInteractionEnabled = true }
        circleMenu.isHidden = false
    }
    
    func cardCollectionViewLayout(_ collectionViewLayout: HFCardCollectionViewLayout, didUnrevealCardAtIndex index: Int) {
        cardCollectionView.cellForItem(at: IndexPath(item: index, section: 0))!.subviews.forEach { $0.isUserInteractionEnabled = false }
        circleMenu.isHidden = true
    }
    
    func cardCollectionViewLayout(_ collectionViewLayout: HFCardCollectionViewLayout, willUnrevealCardAtIndex index: Int) {
        circleMenu.hideButtons(0.5)
    }
}

// MARK: Group Collection View Delegate, Data Source, and Layout Delegate

extension CardListController : UICollectionViewDelegateFlowLayout {
    func groupCollectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return RealmWrapper.shared.groups.count + 1
        return groups.count + 1
    }
    
    func groupCollectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! GroupCollectionCell
        if indexPath.item != 0 {
//            let model = RealmWrapper.shared.groups[indexPath.item - 1]
//            cell.label.text = model.name
            cell.label.text = groups[indexPath.item - 1]
            cell.label.font = UIFont.systemFont(ofSize: groupLabelFontSize)
        } else {
            cell.label.text = "Ungrouped"
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == groupCollectionView {
            if indexPath.item != 0 {
//                let model = RealmWrapper.shared.groups[indexPath.item - 1]
//                let width = (model.name as NSString).size(withAttributes: [.font: UIFont.systemFont(ofSize: UIFont.systemFontSize)]).width
                let width = (groups[indexPath.item - 1] as NSString).size(withAttributes: [.font: UIFont.systemFont(ofSize: groupLabelFontSize)]).width
                return CGSize(width: width + 20, height: collectionView.height)
            } else {
                let width = ("Ungrouped" as NSString).size(withAttributes: [.font: UIFont.systemFont(ofSize: groupLabelFontSize)]).width
                return CGSize(width: width + 20, height: collectionView.height)
            }
        } else {
            return CGSize(width: UIScreen.width, height: UIScreen.width / nameCardWHRatio)
        }
    }
}

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
    }
}
