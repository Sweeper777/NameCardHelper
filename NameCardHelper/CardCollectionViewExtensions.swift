import UIKit
import HFCardCollectionViewLayout

// MARK: Collection View Delegate and Data Source

extension CardListController : UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == cardCollectionView {
            return cardCollectionView(collectionView, numberOfItemsInSection: section)
        } else if collectionView == groupCollectionView {
            return groupCollectionView(collectionView, numberOfItemsInSection: section)
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == cardCollectionView {
            return cardCollectionView(collectionView, cellForItemAt: indexPath)
        } else if collectionView == groupCollectionView {
            return groupCollectionView(collectionView, cellForItemAt: indexPath)
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == cardCollectionView {
            cardCollectionView(collectionView, didSelectItemAt: indexPath)
        }
    }
}

// MARK: Card Collection View Delegate and Data Source

extension CardListController {
    func cardCollectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shownCards.count
    }
    
    func cardCollectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! HFCardCollectionViewCell
        let model = shownCards[indexPath.item]
        cell.subviews.filter { $0 != cell.contentView }.forEach { $0.removeFromSuperview() }
        model.populateView(cell)
        cell.subviews.forEach { $0.isUserInteractionEnabled = false }
        return cell
    }
    
    func cardCollectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        (collectionView.collectionViewLayout as! HFCardCollectionViewLayout).revealCardAt(index: indexPath.item)
    }
}

extension CardListController : HFCardCollectionViewLayoutDelegate {
    func cardCollectionViewLayout(_ collectionViewLayout: HFCardCollectionViewLayout, didRevealCardAtIndex index: Int) {
        cardCollectionView.cellForItem(at: IndexPath(item: index, section: 0))!.subviews.forEach { $0.isUserInteractionEnabled = true }
        circleMenu.isHidden = false
    }
    
    func cardCollectionViewLayout(_ collectionViewLayout: HFCardCollectionViewLayout, didUnrevealCardAtIndex index: Int) {
        cardCollectionView.cellForItem(at: IndexPath(item: index, section: 0))!.subviews.forEach { $0.isUserInteractionEnabled = false }
        circleMenu.isHidden = true
    }
    
    func cardCollectionViewLayout(_ collectionViewLayout: HFCardCollectionViewLayout, willUnrevealCardAtIndex index: Int) {
        circleMenu.hideButtons(0.5)
    }
}
