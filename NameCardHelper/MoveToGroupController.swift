import UIKit
import RealmSwift

class MoveToGroupController : UITableViewController {
    var selectedGroup: Group!
    var groups: Results<Group>!
    weak var delegate: MoveToGroupControllerDelegate?
    
    override func viewDidLoad() {
        groups = RealmWrapper.shared.groups.sorted(byKeyPath: "name")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RealmWrapper.shared.groups.count + 1
    }
    
}
