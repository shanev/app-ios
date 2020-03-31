import Foundation
import CryptoSwift
import RealmSwift

class RealmCENRepo: CENRepo, RealmRepo {

    var realm: Realm

    init(realmProvider: RealmProvider) {
        realm = realmProvider.realm
    }

    func insert(cen: CEN) -> Bool {
        let DBCENObject = realm.objects(RealmCEN.self).filter("CEN = %@", cen.CEN)
        if DBCENObject.count == 0 {
            let newCEN = RealmCEN(cen)
            try! realm.write {
                realm.add(newCEN)
            }
            return true
        } else {
            //duplicate entry: skipping
            return false
        }
    }

    func loadAllCENRecords() -> [CEN]? {
        let DBCENObject = realm.objects(RealmCEN.self).sorted(byKeyPath: "timestamp", ascending: false)
        return DBCENObject.map { CEN(CEN: $0.CEN, timestamp: $0.timestamp) }
    }

    func generateCENData(CENKey : String) -> Data {
        let currentTs : Int64 = Int64(Date().timeIntervalSince1970)
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
}
