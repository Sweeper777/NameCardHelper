import UIKit
import SwiftyUtils
import HFCardCollectionViewLayout
import CircleMenu
import SnapKit
import SCLAlertView
import EmptyDataSet_Swift
import RxRealm
import RxSwift
import RxDataSources

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
    
    let groupLabelFontSize = 17.f
    var selectedGroup: GroupStruct?
    var shownCards: [NameCard]!
    
    var selectedCard: NameCard? {
        if shownCards.count == 1 {
            return shownCards.first
        } else {
            return selectedCardIndex.map { shownCards[$0] }
        }
    }
    
    var selectedCardIndex: Int? {
        if shownCards.count == 1 {
            return 0
        } else {
            let index = (cardCollectionView.collectionViewLayout as! HFCardCollectionViewLayout).revealedIndex
            return index == -1 ? nil : index
        }
    }
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedGroup = GroupStruct(group: .ungrouped)
        shownCards = Array(RealmWrapper.shared.cards.filter(NSPredicate(format: "group.@count == 0")))
        cardCollectionView.dataSource = self
        cardCollectionView.delegate = self
        
        cardCollectionView.emptyDataSetView { (view) in
            view.titleLabelString(NSAttributedString(string: "No Cards"))
                .detailLabelString(NSAttributedString(string: "Tap here to add a new card!"))
                .isScrollAllowed(false)
                .shouldDisplay(true)
                .image(UIImage(named: "no cards"))
                .didTapContentView(self.newPress)
        }
        
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
        groupCollectionView.dataSource = nil
        groupCollectionView.delegate = self
        
        let observable = Observable.collection(from: RealmWrapper.shared.groups.sorted(byKeyPath: "name"))
        let dataSource = RxCollectionViewSectionedAnimatedDataSource<GroupSection>(configureCell:  {
            [weak self] _, collectionView, index, group in
            guard let `self` = self else { return UICollectionViewCell() }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: index) as! GroupCollectionCell
            cell.label.text = group.name
            cell.label.font = UIFont.systemFont(ofSize: self.groupLabelFontSize)
            cell.gestureRecognizers?.removeAll()
            cell.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(self.didLongTapGroupCell)))
            return cell
        })
        observable.map { x -> [GroupSection] in
            let groups = [.ungrouped] + Array(x)
            let groupStructs = groups.map(GroupStruct.init)
            return [GroupSection(items: groupStructs)]
        }
            .bind(to: groupCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        groupCollectionView.rx.modelSelected(GroupStruct.self).bind { [weak self] (group) in
            guard let `self` = self else { return }
            guard group != self.selectedGroup else { return }
            self.selectedGroup = group
            self.reloadCards()
        }.disposed(by: disposeBag)
        
        groupCollectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: .left)
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
    
    @objc func didLongTapGroupCell(gestureRecogniser: UIGestureRecognizer) {
        if gestureRecogniser.state == .began {
            let point = gestureRecogniser.location(ofTouch: 0, in: self.groupCollectionView)
            guard let index = groupCollectionView.indexPathForItem(at: point) else { return }
            guard let groupStruct: GroupStruct = try? groupCollectionView.rx.model(at: index) else { return }
            let group = groupStruct.findCorrespondingGroupObject()
            guard group != .ungrouped else { return }
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title: "Delete \"\(group.name)\"", style: .destructive, handler: {
                [weak self] _ in
                self?.deleteGroup(group)
            }))
            actionSheet.addAction(UIAlertAction(title: "Rename", style: .default, handler: {
                [weak self] _ in
                self?.renameGroup(group)
            }))
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(actionSheet, animated: true, completion: nil)
        }
    }
    
    func deleteGroup(_ group: Group) {
        let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
        alert.addButton("Yes") {
            try? RealmWrapper.shared.realm.write {
                for card in group.nameCards {
                    RealmWrapper.shared.realm.delete(card)
                }
                RealmWrapper.shared.realm.delete(group)
            }
        }
        alert.addButton("No", action: {})
        alert.showWarning("Confirm", subTitle: "Deleting this group will delete all the cards in it. Are you sure?")
    }
    
    func renameGroup(_ group: Group) {
        let dialog = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
        let textField = dialog.addTextField()
        textField.text = group.name
        dialog.addButton("OK") {
            if textField.text! == group.name || textField.text!.trimmed() == "" {
                return
            }
            
            if textField.text! == "Ungrouped" || textField.text! == "New Group" || RealmWrapper.shared.groups.filter("name == %@", textField.text!).count > 0 {
                let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
                alert.addButton("OK", action: {})
                alert.showError("Error", subTitle: "You cannot have a group with this name!")
                return
            }
            try? RealmWrapper.shared.realm.write {
                group.name = textField.text!
            }
        }
        dialog.addButton("Cancel", action: {})
        dialog.showEdit("Rename", subTitle: "Enter a new name:")
    }
    
    func newCard(sourceType: UIImagePickerController.SourceType) {
        let imagePicker = MyImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func newGroup() {
        let dialog = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
        let textField = dialog.addTextField("Group Name")
        dialog.addButton("OK") {
            guard let text = textField.text else { return }
            guard text.trimmed() != "" else { return }
            
            let group = Group()
            group.name = text
            if !group.validateAndShowAlert() {
                return
            }
            
            do {
                try RealmWrapper.shared.realm.write {
                    RealmWrapper.shared.realm.add(group)
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }
        dialog.addButton("Cancel", action: {})
        dialog.showEdit("Enter Name", subTitle: "")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = (segue.destination as? UINavigationController)?.topViewController as? PreviewController,
            let image = sender as? UIImage {
            vc.imageToProcess = image
        } else if let vc = (segue.destination as? UINavigationController)?.topViewController as? ZoomViewController,
            let card = sender as? NameCard {
            vc.card = card
        } else if let vc = (segue.destination as? UINavigationController)?.topViewController as? MoveToGroupController,
            let group = sender as? Group {
            vc.delegate = self
            vc.selectedGroup = group
        } else if let vc = (segue.destination as? UINavigationController)?.topViewController as? AddToContactsController,
            let info = sender as? (NameCard, ExtractedInfo) {
            vc.nameCard = info.0
            vc.extractedInfo = info.1
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    @IBAction func unwindFromNewCard(segue: UIStoryboardSegue) {
        reloadCards()
    }
    
    func reloadCards() {
        if selectedGroup?.name == "Ungrouped" {
            shownCards = Array(RealmWrapper.shared.cards.filter(NSPredicate(format: "group.@count == 0")))
        } else {
            let selectedGroupObject = selectedGroup?.findCorrespondingGroupObject()
            shownCards = (selectedGroupObject?.nameCards).map { Array($0) } ?? []
        }
        cardCollectionView.reloadData()
        (cardCollectionView.collectionViewLayout as! HFCardCollectionViewLayout).unrevealCard()
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
