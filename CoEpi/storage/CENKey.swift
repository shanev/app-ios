import Foundation
import CryptoKit
import RealmSwift
import Security

struct CENKey : Codable {
    var timestamp: Int = Int(Date().timeIntervalSince1970)
    var cenKey: String?
    
    //static var cenKey: String = ""
    static var cenKeyTimestamp: Int = 0
    
    static func generateAndStoreCENKey() -> CENKey {
        //Retrieve last cenKey and cenKeyTimestamp from CENKey
        let latestCENKey = getLatestCENKey()
        let curTimestamp = Int(Date().timeIntervalSince1970)
        if ( ( cenKeyTimestamp == 0 ) || ( roundedTimestamp(ts: curTimestamp) > roundedTimestamp(ts: cenKeyTimestamp) ) ) {
            //generate a new AES Key and store it in local storage
            
            //generate base64string representation of key
            let cenKeyString = computeSymmetricKey()
            print("generated symkey: \(String(describing: cenKeyString))")
            let cenKeyTimestamp = curTimestamp
            
            //Create CENKey and insert/save to Realm
            let newCENKey = CENKey(timestamp: cenKeyTimestamp, cenKey: cenKeyString)
            newCENKey.insert()
            return newCENKey
        } else {
            print("timestamps not different enough to generate new key rounded(currentTS) \(roundedTimestamp(ts: curTimestamp)) rounded(cenKeyTimestamp) \(roundedTimestamp(ts:cenKeyTimestamp)) rawvalues = curts \(curTimestamp) vs cenkeyts = \(cenKeyTimestamp)")
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
            self.cenKeyTimestamp = cenKeysObject[0].timestamp
            return CENKey(timestamp: self.cenKeyTimestamp, cenKey: cenKeysObject[0].CENKey)
        }
    }
    
    static func getCENKeys(limit: Int) -> [CENKey]? {
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
            print("Duplicate Entry: NOT inserting CENKey( ts: \(self.timestamp) , cenKey: \(String(describing: self.cenKey))")
        } else {
            let newCENKey = DBCENKey(_ts: self.timestamp, _cenKey: self.cenKey!)
            try! realm.write {
                realm.add(newCENKey)
            }
        }
    }
}
