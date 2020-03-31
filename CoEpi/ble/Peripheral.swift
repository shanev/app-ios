import Foundation
import CoreBluetooth
import os.log
import RxRelay

protocol PeripheralDelegate: class {
    func onPeripheralStateChange(description: String)
    func onPeripheralContact(_ contact: CEN)
}

protocol PeripheralReactive {
    var peripheralState: PublishRelay<String> { get }
    var peripheralContactSent: PublishRelay<ContactOld> { get }
    var delegate: PeripheralDelegate? {get set}
}

class PeripheralImpl: NSObject, PeripheralReactive {
    let peripheralState: PublishRelay<String> = PublishRelay()
    let peripheralContactSent: PublishRelay<ContactOld> = PublishRelay()
    weak var delegate: PeripheralDelegate?

    private var peripheralManager: CBPeripheralManager!

    private let serviceUuid: CBUUID = CBUUID(nsuuid: Uuids.service)
    private let characteristicUuid: CBUUID = CBUUID(nsuuid: Uuids.characteristic)

    override init() {
        super.init()
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }

    private func startAdvertising() {
        let service = createService()
        peripheralManager.add(service)

        peripheralManager.startAdvertising([
            // NOTE/TODO this identifier is supposed to show directly in discovery. It doesn't. Service is listed in iPhone peripheral.
            CBAdvertisementDataLocalNameKey : "BLEPeripheralApp",

            CBAdvertisementDataServiceUUIDsKey : [serviceUuid]
        ])
    }

    private func createService() -> CBMutableService {
        let service = CBMutableService(type: serviceUuid, primary: true)

        let characteristic = CBMutableCharacteristic(
            type: characteristicUuid,
            properties: [.read],
            value: nil,
            permissions: [.readable]
        )
        service.characteristics = [characteristic]

        os_log("Peripheral manager adding service: %@", log: blePeripheralLog, service)

        return service
    }
}

extension PeripheralImpl: CBPeripheralManagerDelegate {

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .unknown:
            report(state: "unknown")
        case .unsupported:
            report(state: "unsupported")
        case .unauthorized:
            report(state: "unauthorized")
        case .resetting:
            report(state: "resetting")
        case .poweredOff:
            report(state: "poweredOff")
        case .poweredOn:
            report(state: "poweredOn")
            startAdvertising()
        @unknown default:
            os_log("Peripheral state: unknown")
        }
    }

    private func report(state: String) {
        delegate?.onPeripheralStateChange(description: state)
        //Reactive
        peripheralState.accept(state)
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if let error = error {
            os_log("Advertising error: %@", log: blePeripheralLog, type: .error, error.localizedDescription)
        } else {
            os_log("Peripheral manager did add service: %@", log: blePeripheralLog, service)
        }
    }

    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let error = error {
            os_log("Advertising error: %@", log: blePeripheralLog, type: .error, error.localizedDescription)
        } else {
            os_log("Peripheral manager starting advertising", log: blePeripheralLog)
        }
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        os_log("Peripheral manager did receive read request: %@", log: blePeripheralLog, request.description)
        
        let currentCENKey = CENKey.generateAndStoreCENKey()
        let CENData: Data = CEN.generateCENData(CENKey: currentCENKey.cenKey!)
        //*** Scenario 1: https://docs.google.com/document/d/1f65V3PI214-uYfZLUZtm55kdVwoazIMqGJrxcYNI4eg/edit#
        // iOS - Central + iOS - Peripheral -- so commenting out addNewContact
        //addNewContactEvent(with: identifier)
        request.value = CENData
        peripheral.respond(to: request, withResult: .success)
        
        addNewContactEvent(with: currentCENKey.cenKey!)
        
        os_log("Peripheral manager did respond to read request with result: %d", log: blePeripheralLog, CBATTError.success.rawValue)
    }
    

    private func addNewContactEvent(with identifier: String) {
        print("PERIPHERAL: addNewContactEvent called")
        delegate?.onPeripheralContact(CEN(CEN: identifier))
        //Reactive
        peripheralContactSent.accept(ContactOld(
                   identifier: identifier,
                   timestamp: Date(),
                   // TODO preference
                   isPotentiallyInfectious: true
               ))
        
    }
    
}


