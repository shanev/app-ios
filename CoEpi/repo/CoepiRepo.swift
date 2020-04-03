import Foundation
import RxSwift
import os.log

// NOTE: This is interace for possible Rust shared library
// Reports storage unclear, most likely shared lib forwards api call result, we cache in Realm
// For now the caching happens _in_ CoEpiRepo

protocol CoEpiRepo {
    // Infection reports fetched periodically from the API
    var reports: Observable<[CENReport]> { get }

    // Store CEN from other device
    func storeObservedCen(cen: CEN)

    // Send symptoms report
    func sendReport(report: CENReport) -> Completable
}

class CoEpiRepoImpl: CoEpiRepo {
    private let cenRepo: CENRepo
    private let api: Api
    private let cenMatcher: CenMatcher

    let reports: Observable<[CENReport]>

    // last time (unix timestamp) the CENKeys were requested
    // TODO has to be updated. In Android it's currently also not updated.
    private static var lastCENKeysCheck: Int64 = 0

    private let disposeBag = DisposeBag()

    init(cenRepo: CENRepo, api: Api, keysFetcher: CenKeysFetcher, cenMatcher: CenMatcher) {
        self.cenRepo = cenRepo
        self.api = api
        self.cenMatcher = cenMatcher

        reports = keysFetcher.keys
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .map { keys -> [CENKey] in keys.compactMap { key in
                if (cenMatcher.hasMatches(key: key, maxTimestamp: CoEpiRepoImpl.lastCENKeysCheck)) {
                    return key
                } else {
                    return nil
                }
            }}
            .flatMap { matchedKeys -> Observable<[CENReport]> in
                let requests: [Observable<CENReport>] = matchedKeys.map {
                    api.getCenReport(cenKey: $0).asObservable()
                }
                return Observable.merge(requests).toArray().asObservable()
            }
            .observeOn(MainScheduler.instance) // TODO switch to main only in view models
            .share()

        reports.subscribe().disposed(by: disposeBag)
    }

    func storeObservedCen(cen: CEN) {
        if !(cenRepo.insert(cen: cen)) {
            os_log("Observed CEN already in DB: %@", log: blePeripheralLog, type: .debug, "\(cen)")
        }
    }

    func sendReport(report: CENReport) -> Completable {
        api.postCenReport(cenReport: report)
    }
}
