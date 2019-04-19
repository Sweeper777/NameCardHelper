import UIKit
import SwiftyUtils
import HFCardCollectionViewLayout

class ViewController: UIViewController {

    @IBOutlet var groupCollectionView: UICollectionView!
    @IBOutlet var cardCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
