public import Tagged_Primitives

extension Product {
    /// Stable identity for billing/Stripe mapping
    /// Ensures deterministic ID regardless of addon ordering
    public struct SKU: Sendable, Codable, Hashable, Identifiable {
        public typealias ID = Tagged<Self, String>

        public let id: Product.SKU.ID
        public let tier: Tier.ID
        public let addons: [Addon.ID]  // Always sorted for determinism

        public init(
            tier: Tier.ID,
            addons: some Swift.Sequence<Addon.ID>
        ) {
            self.tier = tier
            // Sort addons to ensure consistent ID
            self.addons = Set(addons).sorted { $0.underlying < $1.underlying }

            // Generate deterministic ID
            let addonStr = self.addons.map(\.underlying).joined(separator: "+")
            let idString =
                addonStr.isEmpty
                ? tier.underlying
                : "\(tier.underlying):\(addonStr)"
            self.id = ID(idString)
        }
    }
}

extension Product.SKU {
    // Convenience init from Plan
    public init(from plan: Product.Plan) {
        self.init(tier: plan.tier, addons: plan.addons)
    }
}

extension Product.SKU {
    public static let weekly: Self = .init(tier: .weekly, addons: [])
    public static let daily: Self = .init(tier: .daily, addons: [])
    public static let hourly: Self = .init(tier: .hourly, addons: [])
    public static let dailyWithAnalytics: Self = .init(tier: .daily, addons: [.analytics])
    public static let hourlyWithAnalytics: Self = .init(tier: .hourly, addons: [.analytics])
    public static let weeklyWithAnalytics: Self = .init(tier: .weekly, addons: [.analytics])
}
