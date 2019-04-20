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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        EZLoadingActivity.show("Generating Preview...", disableUI: false)
        let vision = Vision.vision()
        let textRecognizer = vision.onDeviceTextRecognizer()
        let vImage = VisionImage(image: imageToProcess)
        textRecognizer.process(vImage) { [weak self] (result, error) in
            guard error == nil, let result = result else {
                EZLoadingActivity.hide(false, animated: true)
                return
            }
            guard let nameCard = self?.processVisionText(result) else {
                EZLoadingActivity.hide(false, animated: true)
                return
            }
            self?.displayNameCard(nameCard)
            EZLoadingActivity.hide(true, animated: true)
        }
    }
    
}
