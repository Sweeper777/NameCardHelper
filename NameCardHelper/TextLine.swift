import CoreGraphics
import RealmSwift

class TextLine: Object {
    @objc dynamic var x: Double = 0
    @objc dynamic var y: Double = 0
    @objc dynamic var width: Double = 0
    @objc dynamic var height: Double = 0
    @objc dynamic var text = ""
    
    let nameCard = LinkingObjects(fromType: NameCard.self, property: "lines")
    
    var rect: CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
}
