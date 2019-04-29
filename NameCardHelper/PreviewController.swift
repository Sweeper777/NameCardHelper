import UIKit
import Firebase
import EZLoadingActivity
import HFCardCollectionViewLayout
import DECResizeFontToFitRect
import DZLabel

class PreviewController: UIViewController {
    var imageToProcess: UIImage!
    
    @IBOutlet var cardView: UIView!
    @IBOutlet var zoomBarButton: UIBarButtonItem!
    
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
        for block in nameCard.blocks {
            var newFrame = block.rect.applying(CGAffineTransform(scaleX: scaleX - padding, y: scaleY - padding))
            newFrame = newFrame.with(x: newFrame.x + offsetX)
                                .with(y: newFrame.y + offsetY)
            let label = UITextView(frame: newFrame)
            label.backgroundColor = .clear
            label.text = block.text
            label.isScrollEnabled = false
            label.isEditable = false
            label.textContainer.lineFragmentPadding = 0
            label.textContainerInset = .zero
            label.dataDetectorTypes = [.phoneNumber, .link, .address]
            label.textAlignment = .left
            label.font = UIFont(name: "Menlo", size: fontSize(forString: block.text, toFit: label.bounds.size))
            cardView.addSubview(label)
        }
    }
    
    private func sizeForUnitCharacter() -> CGSize {
        let unitChar = NSAttributedString(string: "o", attributes: [.font: UIFont(name: "Menlo", size: 1)!])
        return unitChar.size()
    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
        guard let longestLineCharCount = string.split(separator: "\n").map({ $0.count }).max() else { return 0 }
        let numberOfLines = string.filter { $0 == "\n" }.count + 1
        let unitSize = sizeForUnitCharacter()
        let eachCharacterMaxWidth = size.width / longestLineCharCount.f
        let eachCharacterMaxHeight = size.height / numberOfLines.f
        return min(eachCharacterMaxWidth / unitSize.width, eachCharacterMaxHeight / unitSize.height)
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
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
        }
    }
}
