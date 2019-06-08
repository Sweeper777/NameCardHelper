import RealmSwift
import SCLAlertView

class Group: Object {
    @objc dynamic var name = ""
    let nameCards = List<NameCard>()
    
    static let ungrouped: Group = {
        let retVal = Group()
        retVal.name = "Ungrouped"
        return retVal
    }()
    
    override var description: String {
        return name
    }
    
    static func ==(lhs: Group, rhs: Group) -> Bool {
        return lhs.name == rhs.name
    }
}

extension Group {
    func validateAndShowAlert() -> Bool {
        if ["Ungrouped", "New Group", "None", ""].contains(name.trimmed()) ||
            RealmWrapper.shared.groups.filter("name == %@", name).count > 0 {
            let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
            alert.addButton("OK", action: {})
            alert.showError("Error", subTitle: "You cannot have a group with this name!")
            return false
        } else {
            return true
        }
    }
}

struct GroupStruct {
    let name: String
    
    init(group: Group) {
        name = group.name
    }
    
    func findCorrespondingGroupObject() -> Group {
        if name == Group.ungrouped.name {
            return .ungrouped
        } else {
            return RealmWrapper.shared.groups.filter(NSPredicate(format: "name == %@", name)).first!
        }
    }
}
