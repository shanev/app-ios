import RxSwift
import os.log

protocol CENReportRepo {
    var reports: Observable<[CENReport]> { get }

    func insert(report: CENReport) -> Bool
    func delete(report: CENReport)
}

class CenReportRepoImpl: CENReportRepo {
    private let cenReportDao: CENReportDao
    private let coEpiRepo: CoEpiRepo

    lazy var reports = cenReportDao.reports

    private let disposeBag = DisposeBag()

    init(cenReportDao: CENReportDao, coEpiRepo: CoEpiRepo) {
        self.cenReportDao = cenReportDao
        self.coEpiRepo = coEpiRepo

        coEpiRepo.reports.subscribe(onNext: { reports in
            os_log("Inserting reports in db: %@", type: .debug, reports)
            for report in reports {
                _ = cenReportDao.insert(report: report)
            }
        }, onError: { error in
            os_log("Error: %@", type: .error, error.localizedDescription)
        }).disposed(by: disposeBag)
    }

    func insert(report: CENReport) -> Bool {
        cenReportDao.insert(report: report)
    }

    func delete(report: CENReport) {
        cenReportDao.delete(report: report)
    }
}
