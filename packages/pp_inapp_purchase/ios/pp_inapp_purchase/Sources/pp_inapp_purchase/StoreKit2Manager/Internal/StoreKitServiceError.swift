import Foundation

/// Errors surfaced by StoreKitService when no underlying StoreKit error exists.
internal enum StoreKitServiceError: LocalizedError {
    case entitlementVerificationFailed

    var errorDescription: String? {
        switch self {
        case .entitlementVerificationFailed:
            return "Current entitlement verification failed"
        }
    }
}
