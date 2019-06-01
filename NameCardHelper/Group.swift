import RealmSwift

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
}
