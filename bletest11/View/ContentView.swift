//
//  ContentView.swift
//  bletest11
//
//  Created by User on 2023-12-10.
//

import SwiftUI


struct ContentView: View {
    @ObservedObject private var bluetoothViewModel = BluetoothViewModel()

    var body: some View {
        NavigationView {
            VStack(){
                NavigationLink(destination: InternalSensorVew()) {
                        Text("Use Internal Sensor")
                            .font(.headline)
                            .fontWeight(.bold)
                }
                List(bluetoothViewModel.peripheralNames.filter { $0.hasPrefix("Polar") } , id: \.self)
                { name in
                    Button(action: {
                        if let peripheral = bluetoothViewModel.peripheral(named: name) {
                            bluetoothViewModel.connectToPeripheral(peripheral)
                        }
                    }) {
                        Text(name)
                            .font(name == "Polar Sense B5073A26" ? .headline : .body)
                            .fontWeight(name == "Polar Sense B5073A26" ? .bold : .none)
                    }
                    
                }.navigationTitle("Peripherals")
                    .background(
                        NavigationLink(
                            destination: SensorView().environmentObject(bluetoothViewModel.sensorData),
                            isActive: $bluetoothViewModel.isConnected
                        ) { EmptyView() }
                    )
            }
        }
    }
}

