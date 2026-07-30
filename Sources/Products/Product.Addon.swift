import Dependencies
public import Tagged_Primitives

extension Product {
    // Addon represents optional features that enhance any tier
    public struct Addon: Sendable, Codable, Hashable, Identifiable {
        public typealias ID = Tagged<Self, String>

        public let id: Product.Addon.ID
        public let name: String
        public let displayName: String
        public let description: String
        public let capabilities: Set<Capability>

        public init(
            id: Product.Addon.ID,
            name: String,
            displayName: String,
            description: String,
            capabilities: Set<Capability>
        ) {
            self.id = id
            self.name = name
            self.displayName = displayName
            self.description = description
            self.capabilities = capabilities
        }
    }
}

// Standard addons
extension Product.Addon {
    public static let analytics = Self(
        id: .analytics,
        name: "Analytics Pack",
        displayName: "Analytics Pack",
        description: "Advanced analytics, exports, and API access",
        capabilities: [.advancedAnalytics, .apiAccess]
    )

    // Future addons (defined for planning)
    public static let teamAccess = Self(
        id: .teamAccess,
        name: "Team Access",
        displayName: "Team Collaboration",
        description: "Share analytics with your team",
        capabilities: [.teamAccess]
    )

    public static let customAlerts = Self(
        id: .customAlerts,
        name: "Custom Alerts",
        displayName: "Custom Alerts",
        description: "Set up custom alerts and notifications",
        capabilities: [.customAlerts]
    )

    public static let all: [Self] = [.analytics]
}

// Pricing has been moved to Billing.PricingStrategy

// Static IDs for type-safe access
extension Product.Addon.ID {
    public static let analytics = Self("analytics")
    public static let teamAccess = Self("team")
    public static let customAlerts = Self("alerts")
}
