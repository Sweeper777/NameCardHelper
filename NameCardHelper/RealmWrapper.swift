import RealmSwift

final class RealmWrapper {
    let cards: Results<NameCard>!
    let realm: Realm!
    
    private init() {
        do {
            realm = try Realm()
            cards = realm.objects(NameCard.self)
        } catch let error {
            print(error)
            fatalError()
        }
    }
    
}
