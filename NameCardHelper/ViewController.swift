import UIKit
import SwiftyUtils
import HFCardCollectionViewLayout
import CircleMenu
import SnapKit

class ViewController: UIViewController {

    @IBOutlet var groupCollectionView: UICollectionView!
    @IBOutlet var cardCollectionView: UICollectionView!
    
    let circleMenuItems: [(icon: String, color: UIColor)] = [
        ("delete", UIColor(hex: "a8383b")),
        ("edit", UIColor(hex: "aa9239")),
        ("move", UIColor(hex: "328a2e")),
        ("zoom in", UIColor(hex: "3b3176")),
        ("addContact", UIColor(hex: "246b61")),
        ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cardCollectionView.dataSource = self
        cardCollectionView.delegate = self
        cardCollectionView.backgroundView = UIView()
        
        let layout = cardCollectionView.collectionViewLayout as! HFCardCollectionViewLayout
        layout.cardMaximumHeight = cardCollectionView.width / nameCardWHRatio
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
        let imagePicker = UIImagePickerController()
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
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    @IBAction func unwindFromNewCard(segue: UIStoryboardSegue) {
        cardCollectionView.reloadData()
    }
}

extension ViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) { [ weak self] in
            if let image = info[.originalImage] as? UIImage {
                self?.performSegue(withIdentifier: "showPreview", sender: image)
            }
        }
    }
}

extension ViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return RealmWrapper.shared.cards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! HFCardCollectionViewCell
        let model = RealmWrapper.shared.cards[indexPath.item]
        cell.subviews.filter { $0 != cell.contentView }.forEach { $0.removeFromSuperview() }
        model.populateView(cell)
        cell.subviews.forEach { $0.isUserInteractionEnabled = false }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        (collectionView.collectionViewLayout as! HFCardCollectionViewLayout).revealCardAt(index: indexPath.item)
        collectionView.cellForItem(at: indexPath)!.subviews.forEach { $0.isUserInteractionEnabled = true }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        collectionView.cellForItem(at: indexPath)!.subviews.forEach { $0.isUserInteractionEnabled = false }
    }
}
