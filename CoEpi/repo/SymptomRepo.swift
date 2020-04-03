import Foundation
import RxSwift

protocol SymptomRepo {
    func symptoms() -> [Symptom]

    func submitSymptoms(symptoms: [Symptom]) -> Completable
}

class SymptomRepoImpl: SymptomRepo {
    private let coEpiRepo: CoEpiRepo

    init(coEpiRepo: CoEpiRepo) {
        self.coEpiRepo = coEpiRepo
    }

    private var symptomsData: [Symptom] = [
        Symptom(id: "1", name: "Fever"),
        Symptom(id: "2", name: "Tiredness"),
        Symptom(id: "3", name: "Dry cough"),
        Symptom(id: "4", name: "Muscle aches"),
        Symptom(id: "5", name: "Nasal congestion"),
        Symptom(id: "6", name: "Runny nose"),
        Symptom(id: "7", name: "Sore throat"),
        Symptom(id: "8", name: "Diarrhea"),
        Symptom(id: "9", name: "Difficulty breathing"),
        Symptom(id: "10", name: "Loss of smell/taste"),
        Symptom(id: "11", name: "None of the Above")
    ]
    
    func symptoms() -> [Symptom] {
        symptomsData
    }

    func submitSymptoms(symptoms: [Symptom]) -> Completable {
        // TODO! fetch keys!
        fatalError()
//        coEpiRepo.sendReport(report: symptoms.toCENReport())
    }
}

private extension Sequence where Iterator.Element == Symptom {

    func toCENReport() -> CenReport {
        // TODO (has not been specified yet)
        CenReport(id: "123", report: "TODO symptoms -> CENReport", timestamp: Date().coEpiTimestamp)
    }
}
