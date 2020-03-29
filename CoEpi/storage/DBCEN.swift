import RealmSwift

final class DBCEN : Object {
    @objc dynamic var CEN: String = ""
    @objc dynamic var timestamp: Int = Int(Date().timeIntervalSince1970)
    var latitude: Double? = nil
    var longitude: Double? = nil
    
    override static func primaryKey() -> String? {
        return "CEN"
    }
    
    required init(_cen: String, _ts: Int) {
        self.CEN = _cen
        self.timestamp = _ts
    }
    
    required init() {
        //fatalError("init() has not been implemented")
        self.CEN = ""
        self.timestamp = 0
    }
}
