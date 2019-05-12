import UIKit

class GroupCollectionCell: UICollectionViewCell {
    @IBOutlet var label: UILabel!
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                UIView.animate(withDuration: 0.2) {
                    self.layer.cornerRadius = 3
                    self.backgroundColor = .red
                    self.label.textColor = .white
                }
            } else {
                UIView.animate(withDuration: 0.2) {
                    self.layer.cornerRadius = 0
                    self.backgroundColor = .clear
                    self.label.textColor = .black
                }
            }
        }
    }
}
