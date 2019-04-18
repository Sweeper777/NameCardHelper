import RealmSwift
import UIKit

class NameCard: Object {
    @objc dynamic var color = 0
    let lines = List<TextLine>()
    let group = LinkingObjects(fromType: Group.self, property: "nameCard")
    @objc dynamic var originalImage: Data? = nil
    @objc dynamic var aspectRatio = 0.0
    
}
