import UIKit

class GroupCollectionCell: UICollectionViewCell {
    @IBOutlet var label: UILabel!
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                self.layer.cornerRadius = 3
                self.backgroundColor = .red
                self.label.textColor = .white
            } else {
                self.layer.cornerRadius = 0
                self.backgroundColor = .clear
                self.label.textColor = .black
            }
        }
    }
}
