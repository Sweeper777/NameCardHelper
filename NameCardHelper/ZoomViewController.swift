import UIKit

class ZoomViewController : UIViewController {
    @IBOutlet var cardView: UIView!
    
    var card: NameCard!
    var populated = false
    
    override func viewDidLoad() {
        cardView.layer.cornerRadius = 10
        cardView.clipsToBounds = true
    }
    
    override func viewDidLayoutSubviews() {
        if !populated {
            card.populateView(cardView)
            let heightRatio = self.view.width / self.cardView.height
            let widthRatio = self.view.height / self.cardView.width
            let scaleFactor = min(heightRatio, widthRatio)
            self.cardView.transform = CGAffineTransform(rotationAngle: .pi / 2).scaledBy(x: scaleFactor, y: scaleFactor)
            populated = true
        }
    }
    
    @IBAction func done() {
        dismiss(animated: true, completion: nil)
    }
}
