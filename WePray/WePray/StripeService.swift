import Foundation
import StoreKit

// MARK: - Stripe Configuration
struct StripeConfig {
    // Replace with your actual Stripe publishable key
    static let publishableKey = "pk_test_your_publishable_key_here"
    // Replace with your backend URL
    static let backendBaseURL = "https://your-backend.com/api"

    // Price IDs from Stripe Dashboard
    static let standardMonthlyPriceId = "price_standard_monthly"
    static let premiumMonthlyPriceId = "price_premium_monthly"
}

// MARK: - Payment Intent Response
struct PaymentIntentResponse: Codable {
    let clientSecret: String
    let paymentIntentId: String
    let customerId: String?
}

// MARK: - Subscription Status
struct SubscriptionStatus: Codable {
    let isActive: Bool
    let tier: String
    let expiresAt: Date?
    let willRenew: Bool
}

// MARK: - Payment Error
enum PaymentError: LocalizedError {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case paymentFailed(String)
    case cancelled
    case serverError(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid server URL configuration"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server"
        case .paymentFailed(let message):
            return "Payment failed: \(message)"
        case .cancelled:
            return "Payment was cancelled"
        case .serverError(let message):
            return "Server error: \(message)"
        }
    }
}

// MARK: - Stripe Service
@MainActor
class StripeService: ObservableObject {
    static let shared = StripeService()

    @Published var isProcessingPayment = false
    @Published var currentSubscription: SubscriptionStatus?
    @Published var paymentError: PaymentError?

    private init() {}

    // MARK: - Get Price ID for Tier
    func priceId(for tier: SubscriptionTier) -> String? {
        switch tier {
        case .free:
            return nil
        case .standard:
            return StripeConfig.standardMonthlyPriceId
        case .premium:
            return StripeConfig.premiumMonthlyPriceId
        }
    }

    // MARK: - Create Payment Intent
    func createPaymentIntent(for tier: SubscriptionTier, userId: String) async throws -> PaymentIntentResponse {
        guard let priceId = priceId(for: tier) else {
            throw PaymentError.paymentFailed("Free tier does not require payment")
        }

        guard let url = URL(string: "\(StripeConfig.backendBaseURL)/create-payment-intent") else {
            throw PaymentError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "priceId": priceId,
            "userId": userId,
            "tier": tier.rawValue
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw PaymentError.invalidResponse
            }

            if httpResponse.statusCode != 200 {
                if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let message = errorJson["error"] as? String {
                    throw PaymentError.serverError(message)
                }
                throw PaymentError.serverError("HTTP \(httpResponse.statusCode)")
            }

            let decoder = JSONDecoder()
            return try decoder.decode(PaymentIntentResponse.self, from: data)
        } catch let error as PaymentError {
            throw error
        } catch {
            throw PaymentError.networkError(error)
        }
    }

    // MARK: - Create Subscription
    func createSubscription(for tier: SubscriptionTier, userId: String) async throws -> SubscriptionStatus {
        guard let priceId = priceId(for: tier) else {
            // Free tier - just return active status
            return SubscriptionStatus(isActive: true, tier: "free", expiresAt: nil, willRenew: false)
        }

        guard let url = URL(string: "\(StripeConfig.backendBaseURL)/create-subscription") else {
            throw PaymentError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "priceId": priceId,
            "userId": userId,
            "tier": tier.rawValue
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw PaymentError.invalidResponse
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(SubscriptionStatus.self, from: data)
        } catch let error as PaymentError {
            throw error
        } catch {
            throw PaymentError.networkError(error)
        }
    }

    // MARK: - Fetch Current Subscription
    func fetchSubscriptionStatus(userId: String) async throws -> SubscriptionStatus {
        guard let url = URL(string: "\(StripeConfig.backendBaseURL)/subscription-status?userId=\(userId)") else {
            throw PaymentError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw PaymentError.invalidResponse
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let status = try decoder.decode(SubscriptionStatus.self, from: data)

            await MainActor.run {
                self.currentSubscription = status
            }

            return status
        } catch let error as PaymentError {
            throw error
        } catch {
            throw PaymentError.networkError(error)
        }
    }

    // MARK: - Cancel Subscription
    func cancelSubscription(userId: String) async throws {
        guard let url = URL(string: "\(StripeConfig.backendBaseURL)/cancel-subscription") else {
            throw PaymentError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["userId": userId]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        do {
            let (_, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw PaymentError.invalidResponse
            }
        } catch let error as PaymentError {
            throw error
        } catch {
            throw PaymentError.networkError(error)
        }
    }

    // MARK: - Process Payment (Main Entry Point)
    func processPayment(for tier: SubscriptionTier, userId: String) async -> Result<SubscriptionStatus, PaymentError> {
        isProcessingPayment = true
        paymentError = nil

        defer {
            isProcessingPayment = false
        }

        do {
            // For free tier, just return success
            if tier == .free {
                let status = SubscriptionStatus(isActive: true, tier: "free", expiresAt: nil, willRenew: false)
                currentSubscription = status
                return .success(status)
            }

            // Create subscription on backend
            let status = try await createSubscription(for: tier, userId: userId)
            currentSubscription = status
            return .success(status)
        } catch let error as PaymentError {
            paymentError = error
            return .failure(error)
        } catch {
            let paymentErr = PaymentError.networkError(error)
            paymentError = paymentErr
            return .failure(paymentErr)
        }
    }
}

// MARK: - StoreKit Integration (Apple In-App Purchases)
extension StripeService {
    // Product identifiers for App Store
    static let productIdentifiers: Set<String> = [
        "com.wepray.subscription.standard.monthly",
        "com.wepray.subscription.premium.monthly"
    ]

    func fetchProducts() async -> [Product] {
        do {
            let products = try await Product.products(for: Self.productIdentifiers)
            return products.sorted { $0.price < $1.price }
        } catch {
            print("Failed to fetch products: \(error)")
            return []
        }
    }

    func purchase(_ product: Product) async throws -> Transaction? {
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            return transaction
        case .userCancelled:
            throw PaymentError.cancelled
        case .pending:
            return nil
        @unknown default:
            throw PaymentError.paymentFailed("Unknown purchase result")
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw PaymentError.paymentFailed("Transaction verification failed")
        case .verified(let safe):
            return safe
        }
    }
}
