import Foundation

protocol CENRepo {
    func generateCENData(CENKey : String) -> Data

    func insert(cen: CEN) -> Bool

    func loadAllCENRecords() -> [CEN]?
}
