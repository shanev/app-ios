import RealmSwift

final class DBCENKey : Object {
    @objc dynamic var timestamp: Int = Int(Date().timeIntervalSince1970)
    @objc dynamic var CENKey: String = ""
    var latitude: Double? = nil
    var longitude: Double? = nil
    
    override static func primaryKey() -> String? {
        return "timestamp"
    }
    
    required init( _ts: Int, _cenKey: String ) {
        self.timestamp = _ts
        self.CENKey = _cenKey
    }
    
    required init() {
        //fatalError("init() has not been implemented")
        self.timestamp = Int(Date().timeIntervalSince1970)
        self.CENKey = ""
    }
}
