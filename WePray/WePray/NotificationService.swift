//
//  NotificationService.swift
//  WePray - Push Notifications & Reminders
//

import Foundation
import UserNotifications
import SwiftUI

// MARK: - Notification Type
enum PrayerNotificationType: String, Codable, CaseIterable {
    case prayerReminder = "prayer_reminder"
    case dailyPrayer = "daily_prayer"
    case groupEvent = "group_event"
    case newFollower = "new_follower"
    case postLike = "post_like"
    case groupPost = "group_post"
    case general = "general"

    var title: String {
        switch self {
        case .prayerReminder: return "Prayer Time"
        case .dailyPrayer: return "Daily Prayer"
        case .groupEvent: return "Group Event"
        case .newFollower: return "New Follower"
        case .postLike: return "Post Liked"
        case .groupPost: return "New Group Post"
        case .general: return "WePray"
        }
    }

    var iconName: String {
        switch self {
        case .prayerReminder: return "bell.fill"
        case .dailyPrayer: return "sun.max.fill"
        case .groupEvent: return "calendar"
        case .newFollower: return "person.badge.plus"
        case .postLike: return "heart.fill"
        case .groupPost: return "text.bubble.fill"
        case .general: return "app.badge"
        }
    }
}

// MARK: - Prayer Reminder
struct PrayerReminder: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var message: String
    var time: Date
    var repeatDays: [Int] // 1 = Sunday, 7 = Saturday
    var isEnabled: Bool = true
    var sound: String = "default"

    var repeatDaysDescription: String {
        if repeatDays.count == 7 { return "Every day" }
        if repeatDays.isEmpty { return "Once" }
        let dayNames = ["", "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        return repeatDays.map { dayNames[$0] }.joined(separator: ", ")
    }

    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: time)
    }
}

// MARK: - App Notification
struct AppNotification: Identifiable, Codable {
    var id: UUID = UUID()
    var type: PrayerNotificationType
    var title: String
    var body: String
    var data: [String: String]?
    var timestamp: Date = Date()
    var isRead: Bool = false
}

// MARK: - Notification Settings
struct NotificationSettings: Codable {
    var prayerRemindersEnabled: Bool = true
    var dailyPrayerEnabled: Bool = true
    var dailyPrayerTime: Date = Calendar.current.date(from: DateComponents(hour: 8, minute: 0)) ?? Date()
    var groupNotificationsEnabled: Bool = true
    var socialNotificationsEnabled: Bool = true
    var soundEnabled: Bool = true
    var badgeEnabled: Bool = true
}

// MARK: - Notification Service
@MainActor
class NotificationService: NSObject, ObservableObject {
    static let shared = NotificationService()

    @Published var isAuthorized = false
    @Published var pendingNotifications: [UNNotificationRequest] = []
    @Published var notifications: [AppNotification] = []
    @Published var unreadCount: Int = 0
    @Published var settings = NotificationSettings()
    @Published var reminders: [PrayerReminder] = []

    private let center = UNUserNotificationCenter.current()
    private let settingsKey = "notification_settings"
    private let remindersKey = "prayer_reminders"
    private let notificationsKey = "app_notifications"

    override init() {
        super.init()
        loadSettings()
        loadReminders()
        loadNotifications()
    }

    // MARK: - Authorization
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            await MainActor.run {
                self.isAuthorized = granted
            }
            return granted
        } catch {
            print("Notification authorization error: \(error)")
            return false
        }
    }

    func checkAuthorizationStatus() async {
        let settings = await center.notificationSettings()
        await MainActor.run {
            self.isAuthorized = settings.authorizationStatus == .authorized
        }
    }

    // MARK: - Schedule Prayer Reminder
    func scheduleReminder(_ reminder: PrayerReminder) {
        guard reminder.isEnabled else { return }

        let content = UNMutableNotificationContent()
        content.title = reminder.title
        content.body = reminder.message
        content.sound = settings.soundEnabled ? .default : nil
        content.badge = settings.badgeEnabled ? 1 : nil
        content.userInfo = ["type": PrayerNotificationType.prayerReminder.rawValue]

        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: reminder.time)
        let minute = calendar.component(.minute, from: reminder.time)

        if reminder.repeatDays.isEmpty {
            // One-time reminder
            var dateComponents = calendar.dateComponents([.year, .month, .day], from: reminder.time)
            dateComponents.hour = hour
            dateComponents.minute = minute

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(identifier: reminder.id.uuidString, content: content, trigger: trigger)

            center.add(request) { error in
                if let error = error {
                    print("Failed to schedule reminder: \(error)")
                }
            }
        } else {
            // Repeating reminder for specific days
            for day in reminder.repeatDays {
                var dateComponents = DateComponents()
                dateComponents.weekday = day
                dateComponents.hour = hour
                dateComponents.minute = minute

                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                let identifier = "\(reminder.id.uuidString)_\(day)"
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

                center.add(request) { error in
                    if let error = error {
                        print("Failed to schedule reminder for day \(day): \(error)")
                    }
                }
            }
        }
    }

    // MARK: - Schedule Daily Prayer
    func scheduleDailyPrayer() {
        guard settings.dailyPrayerEnabled else { return }

        let content = UNMutableNotificationContent()
        content.title = "Daily Prayer"
        content.body = "Start your day with prayer. Tap to receive today's personalized prayer."
        content.sound = settings.soundEnabled ? .default : nil
        content.userInfo = ["type": PrayerNotificationType.dailyPrayer.rawValue]

        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: settings.dailyPrayerTime)
        let minute = calendar.component(.minute, from: settings.dailyPrayerTime)

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily_prayer", content: content, trigger: trigger)

        center.add(request) { error in
            if let error = error {
                print("Failed to schedule daily prayer: \(error)")
            }
        }
    }

    // MARK: - Cancel Notifications
    func cancelReminder(_ reminder: PrayerReminder) {
        let identifiers = [reminder.id.uuidString] + (1...7).map { "\(reminder.id.uuidString)_\($0)" }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    func cancelDailyPrayer() { center.removePendingNotificationRequests(withIdentifiers: ["daily_prayer"]) }
    func cancelAllNotifications() { center.removeAllPendingNotificationRequests() }

    // MARK: - Reminder Management
    func addReminder(_ reminder: PrayerReminder) {
        reminders.append(reminder)
        scheduleReminder(reminder)
        saveReminders()
    }

    func removeReminder(_ reminder: PrayerReminder) {
        cancelReminder(reminder)
        reminders.removeAll { $0.id == reminder.id }
        saveReminders()
    }

    func updateReminder(_ reminder: PrayerReminder) {
        cancelReminder(reminder)
        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) { reminders[index] = reminder }
        if reminder.isEnabled { scheduleReminder(reminder) }
        saveReminders()
    }

    // MARK: - In-App Notifications
    func addNotification(_ notification: AppNotification) {
        notifications.insert(notification, at: 0)
        updateUnreadCount()
        saveNotifications()
    }

    func markAsRead(_ notification: AppNotification) {
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            notifications[index].isRead = true
            updateUnreadCount()
            saveNotifications()
        }
    }

    func markAllAsRead() {
        for index in notifications.indices { notifications[index].isRead = true }
        updateUnreadCount()
        saveNotifications()
    }

    func clearNotifications() {
        notifications.removeAll()
        updateUnreadCount()
        saveNotifications()
    }

    private func updateUnreadCount() { unreadCount = notifications.filter { !$0.isRead }.count }

    // MARK: - Persistence
    func saveSettings() {
        if let encoded = try? JSONEncoder().encode(settings) { UserDefaults.standard.set(encoded, forKey: settingsKey) }
        cancelDailyPrayer()
        if settings.dailyPrayerEnabled { scheduleDailyPrayer() }
    }

    private func loadSettings() {
        guard let data = UserDefaults.standard.data(forKey: settingsKey),
              let decoded = try? JSONDecoder().decode(NotificationSettings.self, from: data) else { return }
        settings = decoded
    }

    private func saveReminders() {
        if let encoded = try? JSONEncoder().encode(reminders) { UserDefaults.standard.set(encoded, forKey: remindersKey) }
    }

    private func loadReminders() {
        guard let data = UserDefaults.standard.data(forKey: remindersKey),
              let decoded = try? JSONDecoder().decode([PrayerReminder].self, from: data) else { return }
        reminders = decoded
    }

    private func saveNotifications() {
        if let encoded = try? JSONEncoder().encode(notifications) { UserDefaults.standard.set(encoded, forKey: notificationsKey) }
    }

    private func loadNotifications() {
        guard let data = UserDefaults.standard.data(forKey: notificationsKey),
              let decoded = try? JSONDecoder().decode([AppNotification].self, from: data) else { return }
        notifications = decoded
        updateUnreadCount()
    }

    func fetchPendingNotifications() async {
        let requests = await center.pendingNotificationRequests()
        await MainActor.run { self.pendingNotifications = requests }
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationService: UNUserNotificationCenterDelegate {
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        return [.banner, .sound, .badge]
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let userInfo = response.notification.request.content.userInfo
        if let typeString = userInfo["type"] as? String,
           let type = PrayerNotificationType(rawValue: typeString) {
            print("User tapped notification of type: \(type)")
            // Handle navigation based on notification type
        }
    }
}
