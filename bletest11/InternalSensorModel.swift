//
//  InternalSensorModel.swift
//  bletest11
//
//  Created by User on 2023-12-17.
//

import Foundation
import CoreMotion

class InternalSensorModel: ObservableObject {
    @Published var sensorData = SensorDataModel()
    let motionManager = CMMotionManager()
    let isMessuring = false
    private var timer: Timer?
    
    private let alphaEWMA: Float = 0.1 // Adjust as needed
    private let alphaComplementary: Float = 0.90 // Adjust as needed

    private var prevAccX: Float = 1;
    private var prevAccY: Float = 1;
    private var prevAccZ: Float = 1;
    
    init() {
        startMessurement()
    }
    
    func startMessurement(){
        print("start messurement")
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.1
            motionManager.startAccelerometerUpdates()
        } else {
            print("Accelerometer is not available.")
            return;
        }

        if motionManager.isGyroAvailable {
            motionManager.gyroUpdateInterval = 0.1
            motionManager.startGyroUpdates()
        } else {
            print("Gyroscope is not available.")
            return;
        }
        
        motionManager.startGyroUpdates()
        motionManager.startAccelerometerUpdates()
        
        // Start the timer
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let accelerometerData = self?.motionManager.accelerometerData else  {
                return;
            }
            guard let gyroData = self?.motionManager.gyroData else  {
                return;
            }
            
            if(self == nil){
                return;
            }
            
            self?.prevAccX = self!.applyEWMAFilter(currentInput: Float(accelerometerData.acceleration.x), previousOutput: self!.prevAccX, alpha: self!.alphaEWMA)
            self?.prevAccY = self!.applyEWMAFilter(currentInput: Float(accelerometerData.acceleration.y), previousOutput: self!.prevAccY , alpha: self!.alphaEWMA)
            self?.prevAccZ = self!.applyEWMAFilter(currentInput: Float(accelerometerData.acceleration.z), previousOutput: self!.prevAccZ, alpha: self!.alphaEWMA)
            
            self?.sensorData.xAngle = self!.prevAccX * 100
            self?.sensorData.yAngle = self!.prevAccY * 100
            self?.sensorData.zAngle = self!.prevAccZ * 100
            
            
            self?.sensorData.xAngle2 = self!.applyComplementaryFilter(accelerationInput: self!.prevAccX, gyroscopeInput: Float(gyroData.rotationRate.x), alpha: self!.alphaComplementary)*100;
            self?.sensorData.yAngle2 = self!.applyComplementaryFilter(accelerationInput: self!.prevAccY, gyroscopeInput: Float(gyroData.rotationRate.y), alpha: self!.alphaComplementary)*100;
            self?.sensorData.zAngle2 = self!.applyComplementaryFilter(accelerationInput: self!.prevAccZ, gyroscopeInput: Float(gyroData.rotationRate.z), alpha: self!.alphaComplementary)*100;
        }
    }
    
    func endMessurement(){
        motionManager.stopGyroUpdates();
        motionManager.stopAccelerometerUpdates();
        timer?.invalidate();
    }
    
    private func applyEWMAFilter(currentInput: Float, previousOutput: Float, alpha: Float) -> Float {
        return alpha * currentInput + (1 - alpha) * previousOutput
    }
    
    private func applyComplementaryFilter(accelerationInput: Float, gyroscopeInput: Float, alpha: Float) -> Float {
        return alpha * accelerationInput + (1 - alpha) * gyroscopeInput
    }
}
