import UIKit
import Firebase
import EZLoadingActivity
import HFCardCollectionViewLayout
import DECResizeFontToFitRect
import DZLabel

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
        for line in nameCard.blocks {
            var newFrame = line.rect.applying(CGAffineTransform(scaleX: scaleX - padding, y: scaleY - padding))
            newFrame = newFrame.with(x: newFrame.x + offsetX)
                                .with(y: newFrame.y + offsetY)
            let label = DZLabel(frame: newFrame)
            label.backgroundColor = .clear
            label.dzText = line.text
            label.textAlignment = .left
            label.dzEnabledTypes = [
                .address, .phone, .url
            ]
            label.isScrollEnabled = false
            label.dzFont = resize(font: label.font!,
                                toRect: label.bounds,
                                forString: label.dzText!,
                                withMaxFontSize: 100,
                                withMinFontSize: 0)
            cardView.addSubview(label)
        }
    }
    
    func addLinks(toString string: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string)
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue | NSTextCheckingResult.CheckingType.link.rawValue) else {
            return attributedString
        }
        for match in detector.matches(in: string, options: [], range: NSRange(location: 0, length: string.count)) {
            if match.resultType == .phoneNumber {
                attributedString.addAttributes([.link: "tel://\(match.phoneNumber!)"], range: match.range)
            } else if match.resultType == .link {
                attributedString.addAttributes([.link: string[Range(match.range, in: string)!]], range: match.range)
            }
        }
        return attributedString
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
