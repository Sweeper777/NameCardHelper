import RealmSwift

class Group: Object {
    @objc dynamic var name = ""
    let nameCards = List<NameCard>()
    
    override var description: String {
        return name
    }
}
