//
//  ContentView.swift
//  StudyTimer
//
//  Created by Caleb Atchison on 3/14/25.
//

import SwiftUI

@main
struct StudyTimerApp: App {
    @StateObject var timerModel = TimerModel()
    
    var body: some Scene {
        MenuBarExtra {
            // The content of your popover
            TimerView()
                .environmentObject(timerModel)
        } label: {
            // The label in the menu bar
            HStack {
                Image(systemName: "clock")
                    .frame(width: 20, alignment: .center)
                
                // Display the countdown in the menu bar
                Text(timerModel.timerString)
                    .font(.custom("Menlo", size: 12))
                    .animation(nil, value: timerModel.timerString)
            }
        }
        .menuBarExtraStyle(.window)
    }
}

struct TimerView: View {
    @EnvironmentObject var timerModel: TimerModel
    @State private var editableTime = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack {
            // Shows the remaining time as an editable field when timer is not running, and non-editable when running
            TextField("00:00", text: Binding(
                get: {
                    timerModel.isTimerRunning ? timerModel.timerString : editableTime
                },
                set: { newValue in
                    if !timerModel.isTimerRunning {
                        editableTime = newValue
                    }
                }
            ))
            .textFieldStyle(PlainTextFieldStyle())
            .focused($isTextFieldFocused)
            .onSubmit {
                commitTimerValue()
            }
            .onChange(of: timerModel.isTimerRunning) { newValue in
                if newValue {
                    isTextFieldFocused = false
                }
            }
            .font(.system(size: 60, /*weight: .bold*/ design: .monospaced))
            .multilineTextAlignment(.center)
            .allowsHitTesting(!timerModel.isTimerRunning)  // Instead of disabling, block hit testing so it doesn't gray out
            .onAppear {
                editableTime = timerModel.timerString
            }
            .onReceive(timerModel.$remainingSeconds) { newRemaining in
                if !timerModel.isTimerRunning && newRemaining == 0 {
                    editableTime = timerModel.timerString
                }
            }
            
            // Buttons to control the timer
            HStack {
                Button(timerModel.isTimerRunning ? "Pause" : "Play") {
                    if timerModel.isTimerRunning {
                        timerModel.pauseTimer()
                        // Update editableTime to reflect the current timer value when paused.
                        editableTime = timerModel.timerString
                    } else {
                        // Commit the current value from the text field before starting the timer
                        commitTimerValue()
                        timerModel.startTimer()
                    }
                }
                
                Button("Cancel") {
                    timerModel.cancelTimer()
                    // When cancelling, update the editable text field.
                    editableTime = timerModel.timerString
                }
            }
            
            // Quit button
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .font(.caption2)
        }
        .frame(width: 250, height: 150)
        .padding()
    }
    
    private func commitTimerValue() {
        let components = editableTime.split(separator: ":")
        if components.count == 2,
           let m = Int(components[0].trimmingCharacters(in: .whitespaces)),
           let s = Int(components[1].trimmingCharacters(in: .whitespaces)) {
            timerModel.setTime(minutes: m, seconds: s)
            editableTime = timerModel.timerString
        } else {
            print("Invalid input format")
        }
    }
}
