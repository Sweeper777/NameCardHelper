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
    
    func processVisionText(_ result: VisionText) -> NameCard? {
        let lines = result.blocks.flatMap { $0.lines }
        guard lines.count > 0 else { return nil }
        let surroundingRect = lines.reduce(lines.first!.frame, { $0.union($1.frame) })
        let textLines: [TextLine] = lines.map {
            line in
            let textLine = TextLine()
            textLine.x = Double((line.frame.x - surroundingRect.x) / surroundingRect.width)
            textLine.y = Double((line.frame.y - surroundingRect.y) / surroundingRect.height)
            textLine.width = Double(line.frame.width / surroundingRect.width)
            textLine.height = Double(line.frame.height / surroundingRect.height)
            textLine.text = line.text
            return textLine
        }
        let nameCard = NameCard()
        nameCard.color = 0xffffff
        nameCard.lines.append(objectsIn: textLines)
        nameCard.originalImage = imageToProcess.pngData() ?? imageToProcess.jpegData(compressionQuality: 1)
        nameCard.aspectRatio = Double(surroundingRect.width / surroundingRect.height)
        return nameCard
    }
    
    func displayNameCard(_ nameCard: NameCard) {
        cardView.subviews.forEach { $0.removeFromSuperview() }
        let padding = 5.f
        let scaleX: CGFloat
        let scaleY: CGFloat
        let offsetX: CGFloat
        let offsetY: CGFloat
        if nameCard.aspectRatio.f > cardView.width / cardView.height {
            scaleX = cardView.width
            scaleY = scaleX / nameCard.aspectRatio.f
            offsetX = 0
            offsetY = (cardView.height - scaleY) / 2
        } else {
            scaleY = cardView.height
            scaleX = scaleY * nameCard.aspectRatio.f
            offsetY = 0
            offsetX = (cardView.width - scaleX) / 2
        }
        for line in nameCard.lines {
            var newFrame = line.rect.applying(CGAffineTransform(scaleX: scaleX - padding, y: scaleY - padding))
            newFrame = newFrame.with(x: newFrame.x + offsetX)
                                .with(y: newFrame.y + offsetY)
            let label = UILabel(frame: newFrame)
            label.backgroundColor = .clear
            label.text = line.text
            label.font = label.font.withSize(label.height * 2 / 3)
            label.adjustsFontSizeToFitWidth = true
            label.textAlignment = .center
            label.numberOfLines = 1
            cardView.addSubview(label)
        }
    }
    
}
