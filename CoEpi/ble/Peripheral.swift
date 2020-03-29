import Foundation
import CoreBluetooth
import os.log

protocol PeripheralDelegate: class {
    func onPeripheralStateChange(description: String)
    func onPeripheralContact(_ contact: CEN)
}

class Peripheral: NSObject {
    private weak var delegate: PeripheralDelegate?

    private var peripheralManager: CBPeripheralManager!

    private let serviceUuid: CBUUID = CBUUID(nsuuid: Uuids.service)
    private let characteristicUuid: CBUUID = CBUUID(nsuuid: Uuids.characteristic)

    init(delegate: PeripheralDelegate) {
        self.delegate = delegate

        super.init()
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }

    private func startAdvertising() {
        print("calling startAdvertising")
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

extension Peripheral: CBPeripheralManagerDelegate {

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .unknown:
            report(state: "peripheral.state unknown")
        case .unsupported:
            report(state: "peripheral.state unsupported")
        case .unauthorized:
            report(state: "peripheral.state unauthorized")
        case .resetting:
            report(state: "peripheral.state resetting")
        case .poweredOff:
            report(state: "peripheral.state poweredOff")
        case .poweredOn:
            report(state: "peripheral.state poweredOn")
            startAdvertising()
        @unknown default:
            os_log("Peripheral state: unknown")
        }
    }

    private func report(state: String) {
        delegate?.onPeripheralStateChange(description: state)
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
        
        let currentTimestamp = Int(Date().timeIntervalSince1970)
        let currentCENKey = CENKey.generateAndStoreCENKey()
        let CENData: Data = CEN.generateCENData(CENKey: currentCENKey.cenKey!, currentTs: currentTimestamp)
        //*** Scenario 1: https://docs.google.com/document/d/1f65V3PI214-uYfZLUZtm55kdVwoazIMqGJrxcYNI4eg/edit#
        // iOS - Central + iOS - Peripheral -- so commenting out addNewContact
        //addNewContactEvent(with: identifier)
        request.value = CENData
        peripheral.respond(to: request, withResult: .success)
        
        os_log("Peripheral manager did respond to read request with result: %d", log: blePeripheralLog, CBATTError.success.rawValue)
    }
    
    /* TODO: Later
    private func addNewContactEvent(with identifier: String) {
        print("PERIPHERAL: addNewContactEvent called")
        delegate?.onPeripheralContact(CEN(
            identifier: identifier,
            timestamp: Date(),
            // TODO preference, from React Native
            isPotentiallyInfectious: true
        ))
    }
    */
}
//
//struct Contact {
//    let identifier: UUID
//    let timestamp: Date
//    let isPotentiallyInfectious: Bool
//}
