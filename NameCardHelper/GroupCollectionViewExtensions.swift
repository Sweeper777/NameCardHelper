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
    typealias Item = GroupStruct
    
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

extension GroupStruct : IdentifiableType, Equatable {
    typealias Identity = String
    
    var identity: String {
        return name
    }
    
    static func ==(lhs: GroupStruct, rhs: GroupStruct) -> Bool {
        return lhs.name == rhs.name
    }
}
