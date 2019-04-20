import UIKit
import Firebase
import EZLoadingActivity
import HFCardCollectionViewLayout

class PreviewController: UIViewController {
    var imageToProcess: UIImage!
    
    @IBOutlet var cardView: UIView!
    
    override func viewDidLoad() {
        cardView.layer.cornerRadius = 10
    }
    
}
