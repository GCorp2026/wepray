//
//  CommissionSettingsView.swift
//  WePray - Commission Settings for Super Admin
//

import SwiftUI

struct CommissionSettingsView: View {
    @State private var settings = CommissionSettings()
    @State private var showSaveConfirmation = false
    private let settingsKey = "WePrayCommissionSettings"

    var body: some View {
        Form {
            // Commission Rates Section
            Section {
                commissionSlider(
                    title: "Premium Subscription",
                    value: $settings.premiumCommissionRate,
                    description: "Commission on premium subscriptions"
                )
                commissionSlider(
                    title: "User Referrals",
                    value: $settings.userReferralRate,
                    description: "Reward for referring new users"
                )
                commissionSlider(
                    title: "Event Hosting",
                    value: $settings.eventHostingRate,
                    description: "Commission for hosting paid events"
                )
                commissionSlider(
                    title: "Content Creators",
                    value: $settings.contentCreatorRate,
                    description: "Commission for content contributions"
                )
            } header: {
                Text("Commission Rates")
            } footer: {
                Text("These rates apply to eligible users earning through the platform.")
            }

            // Payout Settings Section
            Section {
                HStack {
                    Text("Minimum Payout")
                    Spacer()
                    TextField("Amount", value: $settings.minimumPayout, format: .currency(code: "USD"))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 100)
                }

                Picker("Payout Schedule", selection: $settings.payoutSchedule) {
                    ForEach(PayoutSchedule.allCases, id: \.self) { schedule in
                        Text(schedule.rawValue).tag(schedule)
                    }
                }
            } header: {
                Text("Payout Settings")
            }

            // Summary Section
            Section {
                summaryRow(title: "Premium Rate", value: settings.premiumCommissionRate)
                summaryRow(title: "Referral Rate", value: settings.userReferralRate)
                summaryRow(title: "Event Rate", value: settings.eventHostingRate)
                summaryRow(title: "Creator Rate", value: settings.contentCreatorRate)
                HStack {
                    Text("Min. Payout")
                        .foregroundColor(AppColors.subtext)
                    Spacer()
                    Text(settings.minimumPayout, format: .currency(code: "USD"))
                        .fontWeight(.medium)
                }
                HStack {
                    Text("Schedule")
                        .foregroundColor(AppColors.subtext)
                    Spacer()
                    Text(settings.payoutSchedule.rawValue)
                        .fontWeight(.medium)
                }
            } header: {
                Text("Current Settings")
            }

            // Last Updated
            Section {
                HStack {
                    Text("Last Updated")
                        .foregroundColor(AppColors.subtext)
                    Spacer()
                    Text(settings.updatedAt, style: .relative)
                        .foregroundColor(AppColors.subtext)
                }
            }

            // Save Button
            Section {
                Button(action: saveSettings) {
                    HStack {
                        Spacer()
                        Text("Save Changes")
                            .fontWeight(.semibold)
                        Spacer()
                    }
                }
                .listRowBackground(AppColors.primary)
                .foregroundColor(.white)
            }
        }
        .navigationTitle("Commission Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: loadSettings)
        .alert("Settings Saved", isPresented: $showSaveConfirmation) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Commission settings have been updated successfully.")
        }
    }

    private func commissionSlider(title: String, value: Binding<Double>, description: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                Spacer()
                Text("\(Int(value.wrappedValue * 100))%")
                    .font(.headline)
                    .foregroundColor(AppColors.primary)
            }
            Slider(value: value, in: 0...0.5, step: 0.01)
                .tint(AppColors.primary)
            Text(description)
                .font(.caption)
                .foregroundColor(AppColors.subtext)
        }
        .padding(.vertical, 4)
    }

    private func summaryRow(title: String, value: Double) -> some View {
        HStack {
            Text(title)
                .foregroundColor(AppColors.subtext)
            Spacer()
            Text("\(Int(value * 100))%")
                .fontWeight(.medium)
        }
    }

    private func loadSettings() {
        if let data = UserDefaults.standard.data(forKey: settingsKey),
           let decoded = try? JSONDecoder().decode(CommissionSettings.self, from: data) {
            settings = decoded
        }
    }

    private func saveSettings() {
        settings.updatedAt = Date()
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: settingsKey)
        }
        showSaveConfirmation = true
    }
}
