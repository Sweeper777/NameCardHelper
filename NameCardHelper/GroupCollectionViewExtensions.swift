import UIKit
import RxDataSources

// MARK: Group Collection View Delegate, Data Source, and Layout Delegate

extension CardListController : UICollectionViewDelegateFlowLayout {

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == groupCollectionView {
                let model: Group = try! collectionView.rx.model(at: indexPath)
                let width = (model.name as NSString).size(withAttributes: [.font: UIFont.systemFont(ofSize: groupLabelFontSize)]).width
                return CGSize(width: width + 20, height: collectionView.height)
            
        } else {
            return CGSize(width: UIScreen.width, height: UIScreen.width / nameCardWHRatio)
        }
    }
    

}

struct GroupSection: AnimatableSectionModelType {
    typealias Item = Group
    
    typealias Identity = String
    
    var items: [Item]
    
    var identity: String {
        return ""
    }
    
    init(original: GroupSection, items: [Item]) {
        self = original
        self.items = items
    }
    
    init(items: [Item]) {
        self.items = items
    }
}

extension Group : IdentifiableType {
    typealias Identity = String
    
    var identity: String {
        return name
    }
}
