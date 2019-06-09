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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        if indexPath.row == 0 {
            cell.textLabel?.text = "Ungrouped"
        } else {
            cell.textLabel?.text = groups[indexPath.row - 1].name
        }
        if selectedGroup.name == cell.textLabel!.text {
            cell.accessoryType = .checkmark
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            selectedGroup = .ungrouped
            delegate?.didSelectGroup(moveToGroupController: self, group: nil)
        } else {
            selectedGroup = groups[indexPath.row - 1]
            delegate?.didSelectGroup(moveToGroupController: self, group: selectedGroup)
        }
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
}
