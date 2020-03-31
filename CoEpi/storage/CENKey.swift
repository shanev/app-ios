import Foundation
import CryptoKit
import RealmSwift
import Security

struct CENKey : Codable {
    var timestamp: Int64 = Int64(Date().timeIntervalSince1970)
    var cenKey: String?
    
    //static var cenKey: String = ""
    static var cenKeyTimestamp: Int64 = 0
    
    static func generateAndStoreCENKey() -> CENKey {
        //Retrieve last cenKey and cenKeyTimestamp from CENKey
        let latestCENKey = getLatestCENKey()
        let curTimestamp = Int64(Date().timeIntervalSince1970)
        if ( ( cenKeyTimestamp == 0 ) || ( roundedTimestamp(ts: curTimestamp) > roundedTimestamp(ts: cenKeyTimestamp) ) ) {
            //generate a new AES Key and store it in local storage
            
            //generate base64string representation of key
            let cenKeyString = computeSymmetricKey()
            let cenKeyTimestamp = curTimestamp
            
            //Create CENKey and insert/save to Realm
            let newCENKey = CENKey(timestamp: cenKeyTimestamp, cenKey: cenKeyString)
            newCENKey.insert()
            return newCENKey
        } else {
            return latestCENKey!
        }
    }

    static func computeSymmetricKey() -> String? {
        var keyData = Data(count: 32) // 32 bytes === 256 bits
        let keyDataCount = keyData.count
        let result = keyData.withUnsafeMutableBytes {
            (mutableBytes: UnsafeMutablePointer) -> Int32 in
            SecRandomCopyBytes(kSecRandomDefault, keyDataCount, mutableBytes)
        }
        if result == errSecSuccess {
            return keyData.base64EncodedString()
        } else {
            return nil
        }
    }
    
    static func getLatestCENKey() -> CENKey? {
        let realm = try! Realm()
        let cenKeysObject = realm.objects(DBCENKey.self).sorted(byKeyPath: "timestamp", ascending: false)
        if cenKeysObject.count == 0 {
            return nil
        } else {
            self.cenKeyTimestamp = cenKeysObject.first?.timestamp ?? Int64(Date().timeIntervalSince1970)
            return CENKey(timestamp: self.cenKeyTimestamp, cenKey: cenKeysObject[0].CENKey)
        }
    }
    
    static func getCENKeys(limit: Int64) -> [CENKey]? {
        let realm = try! Realm()
        let cenKeysObject = realm.objects(DBCENKey.self).sorted(byKeyPath: "timestamp", ascending: false)
        if cenKeysObject.count == 0 {
            return []
        } else {
            var retrievedCENKeyList:[CENKey] = []
            for index in 0..<cenKeysObject.count {
                retrievedCENKeyList.append(CENKey(timestamp: cenKeysObject[index].timestamp, cenKey: cenKeysObject[index].CENKey))
                if retrievedCENKeyList.count >= limit {
                    break
                }
            }
            return retrievedCENKeyList
        }
    }
    
    func insert() {
        let realm = try! Realm()
        let sameObject = realm.objects(DBCENKey.self).filter("timestamp = %@", self.timestamp)
        if sameObject.count > 0 {
            //Duplicate Entry: NOT inserting
        } else {
            let newCENKey = DBCENKey(_ts: self.timestamp, _cenKey: self.cenKey!)
            try! realm.write {
                realm.add(newCENKey)
            }
        }
    }
}
