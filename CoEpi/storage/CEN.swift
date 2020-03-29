import Foundation
import CryptoSwift
import RealmSwift

struct CEN : Codable {
    var CEN: String
    var timestamp: Int = Int(Date().timeIntervalSince1970)
    var latitude: Double? = nil
    var longitude: Double? = nil
    
    static func generateCENData(CENKey : String, currentTs : Int)  -> Data {
        // decode the base64 encoded key
        let decodedCENKey:Data = Data(base64Encoded: CENKey)!
        
        //convert key to [UInt8]
        var decodedCENKeyAsUInt8Array: [UInt8] = []
        decodedCENKey.withUnsafeBytes {
            decodedCENKeyAsUInt8Array.append(contentsOf: $0)
        }
        
        //convert timestamp to [UInt8]
        var tsAsUInt8Array: [UInt8] = []
        [roundedTimestamp(ts: currentTs)].withUnsafeBytes {
            tsAsUInt8Array.append(contentsOf: $0)
        }
        
        //encrypt tsAsUnit8Array using decodedCENKey... using AES
        let encData = try! AES(key: decodedCENKeyAsUInt8Array, blockMode: ECB(), padding: .pkcs5).encrypt(tsAsUInt8Array)
        
        //return Data representation of encodedData
        return NSData(bytes: encData, length: Int(encData.count)) as Data
    }
    
    func insert() -> Bool {
        let realm = try! Realm()
        print("querying for \(self.CEN)")
        let DBCENObject = realm.objects(DBCEN.self).filter("CEN = %@", self.CEN)
        if DBCENObject.count == 0 {
            let newCEN = DBCEN(_cen: self.CEN, _ts: self.timestamp)
            try! realm.write {
                realm.add(newCEN)
            }
            return true
        } else {
            print("duplicate entry: skipping")
            return false
        }
    }
}

func loadAllCENRecords() -> [CEN]? {
    let realm = try! Realm()
    let DBCENObject = realm.objects(DBCEN.self).sorted(byKeyPath: "timestamp", ascending: false)
    if DBCENObject.count == 0 {
        return nil
    } else {
        var newCENList:[CEN] = []
        for index in 0..<DBCENObject.count {
            newCENList.append(CEN(CEN: DBCENObject[index].CEN, timestamp: DBCENObject[index].timestamp))
        }
        return newCENList
    }
}
