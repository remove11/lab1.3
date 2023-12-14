//
//  BluetoothViewModel.swift
//  bletest11
//
//  Created by User on 2023-12-14.
//

import Foundation
import CoreBluetooth
import SwiftUI
import Combine

class BluetoothViewModel: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private var centralManager: CBCentralManager?
    private var peripherals: [CBPeripheral] = []
    var peripheralBLE: CBPeripheral?
    var sensorDataModel: SensorDataModel?
    private var lastUpdateTime = Date()

    @Published var peripheralNames: [String] = []
    @Published var isConnected = false
    @Published var sensorData = SensorDataModel()
    
    private var previousXAngle: Float = 0.0
    private var previousYAngle: Float = 0.0
    private var previousZAngle: Float = 0.0
    private var previousXAngle2: Float = 0.0
    private var previousYAngle2: Float = 0.0
    private var previousZAngle2: Float = 0.0
    private let alphaEWMA: Float = 0.95 // Adjust as needed
    private let alphaComplementary: Float = 0.90 // Adjust as needed
    
    private var tempX: Float = 0.0
    private var tempY: Float = 0.0
    private var tempZ: Float = 0.0
    
    private var xAngleBuffer: [Float] = []
    private var yAngleBuffer: [Float] = []
    private var zAngleBuffer: [Float] = []
    private let bufferSize = 5  // Number of samples for moving average

    let GATTService = CBUUID(string: "fb005c80-02e7-f387-1cad-8acd2d8df0c8")
    let GATTCommand = CBUUID(string: "fb005c81-02e7-f387-1cad-8acd2d8df0c8")
    let GATTData = CBUUID(string: "fb005c82-02e7-f387-1cad-8acd2d8df0c8")
    
    override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: .main)
    }
    
    enum Axis {
        case xAxis, yAxis, zAxis
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            centralManager?.scanForPeripherals(withServices: nil)
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !peripherals.contains(peripheral) {
            peripherals.append(peripheral)
            peripheralNames.append(peripheral.name ?? "unnamed device")
        }
    }

    func connectToPeripheral(_ peripheral: CBPeripheral) {
        self.peripheralBLE = peripheral
        self.peripheralBLE?.delegate = self
        centralManager?.connect(peripheralBLE!, options: nil)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.isConnected = true
        peripheral.discoverServices([GATTService])
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            peripheral.discoverCharacteristics([GATTData, GATTCommand], for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            if characteristic.uuid == GATTData {
                peripheral.setNotifyValue(true, for: characteristic)
            }
            if characteristic.uuid == GATTCommand {
                // Example command - replace with actual command
                let parameterGyr: [UInt8]  = [0x02, 0x05, 0x00, 0x01, 0x34, 0x00, 0x01, 0x01, 0x10, 0x00, 0x02, 0x01, 0xD0, 0x07, 0x04, 0x01, 0x03]
                let dataGyr = Data(bytes: parameterGyr, count: 17)
                //let parameteAcc: [UInt8] = [0x02, 0x02, 0x00, 0x01, 0x34, 0x00, 0x01, 0x01, 0x10, 0x00, 0x02, 0x01, 0x08, 0x00, 0x04, 0x01, 0x03]
                //let dataAcc = Data(bytes: parameteAcc, count: 17)
                peripheral.writeValue(dataGyr, for: characteristic, type: .withResponse)
                //peripheral.writeValue(dataAcc, for: characteristic, type: .withResponse)
                
            }
            
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
            if let error = error {
                print("Error writing value to characteristic: \(error)")
                return
            }

            if characteristic.uuid == GATTCommand {
                let parameteAcc: [UInt8] = [0x02, 0x02, 0x00, 0x01, 0x34, 0x00, 0x01, 0x01, 0x10, 0x00, 0x02, 0x01, 0x08, 0x00, 0x04, 0x01, 0x03]
                let dataAcc = Data(bytes: parameteAcc, count: 17)

                //peripheral.writeValue(dataAcc as Data, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                peripheral.writeValue(dataAcc, for: characteristic, type: .withResponse)

            }
        }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        
        print("New data")
        let data = characteristic.value
        var byteArray: [UInt8] = []
        for i in data! {
            let n : UInt8 = i
            byteArray.append(n)
        }
        
        var offset = 0
        let measId = data![offset]
        offset += 1
        
        let timeBytes = data!.subdata(in: 1..<9) as NSData
        var timeStamp: UInt64 = 0
        memcpy(&timeStamp,timeBytes.bytes,8)
        offset += 8
        
        let frameType = data![offset]
        offset += 1
    
        print("MessageID:\(measId) Time:\(timeStamp) Frame Type:\(frameType)")
        
        let xBytes = data!.subdata(in: offset..<offset+2) as NSData
        var xSample: Int16 = 0
        memcpy(&xSample,xBytes.bytes,2)
        offset += 2
        
        let yBytes = data!.subdata(in: offset..<offset+2) as NSData
        var ySample: Int16 = 0
        memcpy(&ySample,yBytes.bytes,2)
        offset += 2
        
        let zBytes = data!.subdata(in: offset..<offset+2) as NSData
        var zSample: Int16 = 0
        memcpy(&zSample,zBytes.bytes,2)
        offset += 2
        
        print("xRef:\(xSample >> 11) yRef:\(ySample >> 11) zRef:\(zSample >> 11)")
        
        let deltaSize = UInt16(data![offset])
        offset += 1
        let sampleCount = UInt16(data![offset])
        offset += 1
        
        print("deltaSize:\(deltaSize) Sample Count:\(sampleCount)")

        let bitLength = (sampleCount*deltaSize*UInt16(3))
        let length = Int(ceil(Double(bitLength)/8.0))
        let frame = data!.subdata(in: offset..<(offset+length))

        let deltas = BluetoothViewModel.parseDeltaFrame(frame, channels: UInt16(3), bitWidth: deltaSize, totalBitLength: bitLength)
        
        deltas.forEach { (delta) in
            xSample = xSample &+ delta[0]
            ySample = ySample &+ delta[1]
            zSample = zSample &+ delta[2]
            
            
            switch measId {
                case 2:
                    processAccelerometerData(xSample, ySample, zSample)
                case 5:
                    processGyroscopeData(xSample, ySample, zSample)
                default:
                    print("Unknown measurement ID: \(measId)")
                }
            
            //print("xDelta:\(xSample) yDelta:\(ySample) zDelta:\(zSample)")
            // delat på 4096
        }
    }
    
    func processAccelerometerData(_ xSample: Int16, _ ySample: Int16, _ zSample: Int16) {
       
        
        let xAngleRaw = atan2(Float(ySample), Float(zSample)) * (180 / .pi)
        let yAngleRaw = atan2(Float(xSample), Float(zSample)) * (180 / .pi)
        let zAngleRaw = atan2(sqrt(Float(xSample) * Float(xSample) + Float(ySample) * Float(ySample)), Float(zSample)) * (180 / .pi)
        // Apply EWMA filter
        let filteredXAngle = applyEWMAFilter(currentInput: xAngleRaw, previousOutput: previousXAngle, alpha: alphaEWMA)
        let filteredYAngle = applyEWMAFilter(currentInput: yAngleRaw, previousOutput: previousYAngle, alpha: alphaEWMA)
        let filteredZAngle = applyEWMAFilter(currentInput: zAngleRaw, previousOutput: previousZAngle, alpha: alphaEWMA)
        
        tempX = xAngleRaw
        tempY = yAngleRaw
        tempZ = zAngleRaw
        
        previousXAngle = filteredXAngle
        previousYAngle = filteredYAngle
        previousZAngle = filteredZAngle

        DispatchQueue.main.async {
            self.sensorData.xValue = Float(xSample) / 4096.0
            self.sensorData.yValue = Float(ySample) / 4096.0
            self.sensorData.zValue = Float(zSample) / 4096.0
            self.sensorData.xAngle = filteredXAngle
            self.sensorData.yAngle = filteredYAngle
            self.sensorData.zAngle = filteredZAngle
        }
    }
    
    func processGyroscopeData(_ xSample: Int16, _ ySample: Int16, _ zSample: Int16) {
        
        let filteredXAngle2 = applyComplementaryFilter(accelerationInput: tempX, gyroscopeInput: Float(xSample), alpha: alphaComplementary)
        let filteredYAngle2 = applyComplementaryFilter(accelerationInput: tempY, gyroscopeInput: Float(ySample), alpha: alphaComplementary)
        let filteredZAngle2 = applyComplementaryFilter(accelerationInput: tempZ, gyroscopeInput: Float(zSample), alpha: alphaComplementary)

        
        DispatchQueue.main.async {
            self.sensorData.xDps = Float(xSample) / 16.384
            self.sensorData.yDps = Float(ySample) / 16.384
            self.sensorData.zDps = Float(zSample) / 16.384
            self.sensorData.xAngle2 = filteredXAngle2
            self.sensorData.yAngle2 = filteredYAngle2
            self.sensorData.zAngle2 = filteredZAngle2
        }
    }
    

    func peripheral(named name: String) -> CBPeripheral? {
        guard let index = peripheralNames.firstIndex(of: name) else { return nil }
        return peripherals[index]
    }
    
 
    func applyEWMAFilter(currentInput: Float, previousOutput: Float, alpha: Float) -> Float {
        return alpha * currentInput + (1 - alpha) * previousOutput
    }
    func applyComplementaryFilter(accelerationInput: Float, gyroscopeInput: Float, alpha: Float) -> Float {
        return alpha * accelerationInput + (1 - alpha) * gyroscopeInput
    }
    
    static func parseDeltaFrame(_ data: Data, channels: UInt16, bitWidth: UInt16, totalBitLength: UInt16) -> [[Int16]]{
        // convert array to bits
        let dataInBits = data.flatMap { (byte) -> [Bool] in
            return Array(stride(from: 0, to: 8, by: 1).map { (index) -> Bool in
                return (byte & (0x01 << index)) != 0
            })
        }
        
        let mask = Int16.max << Int16(bitWidth-1)
        let channelBitsLength = bitWidth*channels
        
        return Array(stride(from: 0, to: totalBitLength, by: UInt16.Stride(channelBitsLength)).map { (start) -> [Int16] in
            return Array(stride(from: start, to: UInt16(start+UInt16(channelBitsLength)), by: UInt16.Stride(bitWidth)).map { (subStart) -> Int16 in
                let deltaSampleList: ArraySlice<Bool> = dataInBits[Int(subStart)..<Int(subStart+UInt16(bitWidth))]
                var deltaSample: Int16 = 0
                var i=0
                deltaSampleList.forEach { (bitValue) in
                    let bit = Int16(bitValue ? 1 : 0)
                    deltaSample |= (bit << i)
                    i += 1
                }
                
                if((deltaSample & mask) != 0) {
                    deltaSample |= mask;
                }
                return deltaSample
            })
        })
    }
}
