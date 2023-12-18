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

    
    
    init() {
    }
    
    func startMessurement(){
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
            
            self?.sensorData.xAngle = 10;
            self?.sensorData.yAngle = 10;
            self?.sensorData.xAngle = 10;	
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
