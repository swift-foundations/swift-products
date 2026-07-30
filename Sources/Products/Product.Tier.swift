import Dependencies
public import Tagged_Primitives

extension Product {
    // Tier represents the base data freshness product
    public struct Tier: Sendable, Codable, Hashable, Identifiable {
        public typealias ID = Tagged<Self, String>

        public let id: Product.Tier.ID
        public let name: String
        public let displayName: String
        public let description: String
        public let refreshRate: RefreshRate
        public let baseCapabilities: Set<Capability>

        public init(
            id: Product.Tier.ID,
            name: String,
            displayName: String,
            description: String,
            refreshRate: RefreshRate,
            baseCapabilities: Set<Capability> = []
        ) {
            self.id = id
            self.name = name
            self.displayName = displayName
            self.description = description
            self.refreshRate = refreshRate
            self.baseCapabilities = baseCapabilities
        }
    }
}

// Standard tiers
extension Product.Tier {
    public static let weekly = Self(
        id: .weekly,
        name: "Free",
        displayName: "Weekly Fresh Data",
        description: "Weekly data refresh with basic analytics",
        refreshRate: .weekly,
        baseCapabilities: [.basicAnalytics]
    )

    public static let daily = Self(
        id: .daily,
        name: "Daily",
        displayName: "Daily Fresh Data",
        description: "Daily polling for all your repositories",
        refreshRate: .daily,
        baseCapabilities: [.basicAnalytics, .csvExport]
    )

    public static let hourly = Self(
        id: .hourly,
        name: "Hourly",
        displayName: "Hourly Fresh Data",
        description: "Hourly polling for real-time insights",
        refreshRate: .hourly,
        baseCapabilities: [.basicAnalytics, .csvExport, .excelExport, .pdfExport]
    )

    // Future tier (defined for planning)
    public static let realtime = Self(
        id: .realtime,
        name: "Realtime",
        displayName: "Real-time Data",
        description: "Real-time updates via webhooks",
        refreshRate: .realtime,
        baseCapabilities: [.basicAnalytics, .allExports, .webhooks]
    )

    public static let all: [Self] = [.weekly, .daily, .hourly]
}

// Pricing has been moved to Billing.PricingStrategy

// Static IDs for type-safe access
extension Product.Tier.ID {
    public static let weekly = Self("weekly")
    public static let daily = Self("daily")
    public static let hourly = Self("hourly")
    public static let realtime = Self("realtime")
}

extension Product.Tier.ID {
    // Helper computed properties
    //
    // `public`, not `package`: this was package-visible while Products lived inside
    // its original server package, where the account layer reached it across targets
    // of that same package.
    // Extraction put a package boundary between them and `package` access does not
    // cross one, so the helper joins this package's public surface rather than having
    // its one consumer reimplement display logic the catalogue owns.
    public func currentPlanDisplayName(hasAnalyticsPack: Bool) -> String {
        var name =
            Product.Tier.all.first(where: { $0.id == self })?.displayName
            ?? Product.Tier.weekly.displayName
        if hasAnalyticsPack {
            name += " + Analytics"
        }
        return name
    }
}

extension Product {
    public enum RefreshRate: String, Codable, Sendable {
        case weekly
        case daily
        case hourly
        case realtime

        public var interval: Duration {
            switch self {
            case .weekly: return .seconds(86400 * 7)
            case .daily: return .seconds(86400)
            case .hourly: return .seconds(3600)
            case .realtime: return .seconds(0)
            }
        }
    }

    public enum Capability: String, Codable, Sendable {
        // Data access
        case basicAnalytics = "basic_analytics"
        case advancedAnalytics = "advanced_analytics"  // From analytics addon
        case apiAccess = "api_access"  // From analytics addon

        // Export formats
        case csvExport = "csv_export"
        case excelExport = "excel_export"
        case pdfExport = "pdf_export"
        case allExports = "all_exports"

        // Future capabilities
        case webhooks = "webhooks"
        case teamAccess = "team_access"
        case customAlerts = "custom_alerts"
    }
}
