import Foundation
import RealmSwift

struct CENReport : Codable {
    let CENReportID: String
    let report: String
    let reportMimeType: String
    let reportTimestamp: Int64
    let CENKeys: String
    let isUser: Bool
    
    func insert() -> Bool {
        let realm = try! Realm()
        let DBCENReportObject = realm.objects(DBCENReport.self).filter("CENReportID = %@", self.CENReportID)
        if DBCENReportObject.count == 0 {
            let newCENReport = DBCENReport(_report: self.report , _cenKeys: CENKeys , _ts: reportTimestamp )
            try! realm.write {
                realm.add(newCENReport)
            }
            return true
        } else {
            //duplicate entry: skipping
            return false
        }
    }
}
