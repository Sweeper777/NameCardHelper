import UIKit

// MARK: Group Collection View Delegate, Data Source, and Layout Delegate

extension CardListController : UICollectionViewDelegateFlowLayout {
    func groupCollectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //        return RealmWrapper.shared.groups.count + 1
        return groups.count + 1
    }
    
    func groupCollectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! GroupCollectionCell
        if indexPath.item != 0 {
            //            let model = RealmWrapper.shared.groups[indexPath.item - 1]
            //            cell.label.text = model.name
            cell.label.text = groups[indexPath.item - 1]
            cell.label.font = UIFont.systemFont(ofSize: groupLabelFontSize)
        } else {
            cell.label.text = "Ungrouped"
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == groupCollectionView {
            if indexPath.item != 0 {
                //                let model = RealmWrapper.shared.groups[indexPath.item - 1]
                //                let width = (model.name as NSString).size(withAttributes: [.font: UIFont.systemFont(ofSize: UIFont.systemFontSize)]).width
                let width = (groups[indexPath.item - 1] as NSString).size(withAttributes: [.font: UIFont.systemFont(ofSize: groupLabelFontSize)]).width
                return CGSize(width: width + 20, height: collectionView.height)
            } else {
                let width = ("Ungrouped" as NSString).size(withAttributes: [.font: UIFont.systemFont(ofSize: groupLabelFontSize)]).width
                return CGSize(width: width + 20, height: collectionView.height)
            }
        } else {
            return CGSize(width: UIScreen.width, height: UIScreen.width / nameCardWHRatio)
        }
    }
}
