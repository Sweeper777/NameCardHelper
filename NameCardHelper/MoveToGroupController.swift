import UIKit
import RealmSwift

class MoveToGroupController : UITableViewController {
    var selectedGroup: Group!
    var groups: Results<Group>!
    weak var delegate: MoveToGroupControllerDelegate?
}
