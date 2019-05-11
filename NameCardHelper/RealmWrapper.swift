import RealmSwift

final class RealmWrapper {
    let cards: Results<NameCard>!
    let groups: Results<Group>!
    let realm: Realm!
    
    private init() {
        do {
            realm = try Realm()
            cards = realm.objects(NameCard.self)
            groups = realm.objects(Group.self)
        } catch let error {
            print(error)
            fatalError()
        }
    }
    
    private static var _shared: RealmWrapper?
    
    static var shared: RealmWrapper {
        _shared = _shared ?? RealmWrapper()
        return _shared!
    }
}
