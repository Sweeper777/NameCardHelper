import UIKit
import Firebase
import EZLoadingActivity
import HFCardCollectionViewLayout

class PreviewController: UIViewController {
    var imageToProcess: UIImage!
    var nameCard: NameCard!
    
    @IBOutlet var cardView: UIView!
    @IBOutlet var zoomBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        cardView.layer.cornerRadius = 10
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if cardView.subviews.count > 0 {
            return
        }
        
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
            self?.nameCard = nameCard
            self.map { nameCard.populateView($0.cardView) }
            EZLoadingActivity.hide(true, animated: true)
        }
    }
    
    func processVisionText(_ result: VisionText) -> NameCard? {
        let blocks = result.blocks
        guard blocks.count > 0 else { return nil }
        let surroundingRect = blocks.reduce(blocks.first!.frame, { $0.union($1.frame) })
        let textBlocks: [TextBlock] = blocks.map {
            block in
            let textBlock = TextBlock()
            textBlock.x = Double((block.frame.x - surroundingRect.x) / surroundingRect.width)
            textBlock.y = Double((block.frame.y - surroundingRect.y) / surroundingRect.height)
            textBlock.width = Double(block.frame.width / surroundingRect.width)
            textBlock.height = Double(block.frame.height / surroundingRect.height)
            textBlock.text = block.lines.map { $0.text }.joined(separator: "\n")
            return textBlock
        }
        let nameCard = NameCard()
        nameCard.color = 0xffffff
        nameCard.blocks.append(objectsIn: textBlocks)
        nameCard.originalImage = imageToProcess.pngData() ?? imageToProcess.jpegData(compressionQuality: 1)
        nameCard.aspectRatio = Double(surroundingRect.width / surroundingRect.height)
        return nameCard
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func zoom() {
        if cardView.transform == .identity {
            zoomBarButton.image = UIImage(named: "zoom out")
            UIView.animate(withDuration: 0.3) {
                let heightRatio = self.view.width / self.cardView.height
                let widthRatio = self.view.height / self.cardView.width
                let scaleFactor = min(heightRatio, widthRatio)
                self.cardView.transform = CGAffineTransform(rotationAngle: .pi / 2).scaledBy(x: scaleFactor, y: scaleFactor)
            }
        } else {
            zoomBarButton.image = UIImage(named: "zoom in")
            UIView.animate(withDuration: 0.3) {
                self.cardView.transform = .identity
            }
        }
    }
    
    @IBAction func next() {
        performSegue(withIdentifier: "showOptions", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? CardOptionsController {
            vc.nameCard = nameCard
            vc.image = imageToProcess
        }
    }
}
