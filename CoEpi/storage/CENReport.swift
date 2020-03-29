import Foundation
import RealmSwift

struct CENReport : Codable {
    var CENReportID: String = ""
    var report: String = ""
    var reportMimeType: String = ""
    var reportTimestamp: Int = 0
    var CENKeys: String = ""
    var isUser: Bool = false
    
    func insert() -> Bool {
        let realm = try! Realm()
        print("inserting for \(self.CENReportID) ... already exist?")
        let DBCENReportObject = realm.objects(DBCENReport.self).filter("CENReportID = %@", self.CENReportID)
        if DBCENReportObject.count == 0 {
            let newCENReport = DBCENReport(_report: self.report , _cenKeys: CENKeys , _ts: reportTimestamp )
            try! realm.write {
                realm.add(newCENReport)
            }
            return true
        } else {
            print("duplicate entry: skipping")
            return false
        }
    }
}
