//
//  TimerModel.swift
//  StudyTimer
//
//  Created by Caleb Atchison on 3/14/25.
//

import SwiftUI
import Combine
import UserNotifications

class TimerModel: ObservableObject {
    /// Total seconds for the countdown
    @Published var totalSeconds: Int = 0
    
    /// Current remaining seconds
    @Published var remainingSeconds: Int = 0
    
    /// Whether the timer is running
    @Published var isTimerRunning = false
    
    private var timer: AnyCancellable?
    
    init() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification authorization error: \(error.localizedDescription)")
            } else {
                print("Notification permission granted: \(granted)")
            }
        }
    }
    
    /// Formats the remaining time as MM:SS
    var timerString: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    /// Set the total countdown time in minutes & seconds
    func setTime(minutes: Int, seconds: Int) {
        totalSeconds = max(0, minutes * 60 + seconds)
        remainingSeconds = totalSeconds
    }
    
    /// Start/resume the countdown
    func startTimer() {
        guard !isTimerRunning else { return }
        
        isTimerRunning = true
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                if self.remainingSeconds > 0 {
                    self.remainingSeconds -= 1
                } else {
                    // Timer finished; reset or stop as needed
                    self.cancelTimer()
                    self.scheduleNotification()
                }
            }
    }
    
    func pauseTimer() {
        guard isTimerRunning else { return }
        
        isTimerRunning = false
        timer?.cancel()
    }
    
    func cancelTimer() {
        isTimerRunning = false
        timer?.cancel()
        remainingSeconds = 0  // now the timer displays "00:00"
    }
    
    func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Timer Finished"
        content.body = "Your timer has finished!"
        content.sound = UNNotificationSound.default
        
        // Trigger immediately
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
}
