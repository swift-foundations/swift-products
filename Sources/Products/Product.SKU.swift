public import Tagged_Primitives

extension Product {

    public struct SKU: Sendable, Codable, Hashable, Identifiable {
        public typealias ID = Tagged<Self, String>

        public let id: Product.SKU.ID
        public let tier: Tier.ID
        public let addons: [Addon.ID]

        public init(
            tier: Tier.ID,
            addons: some Swift.Sequence<Addon.ID>
        ) {
            self.tier = tier

            self.addons = Set(addons).sorted { $0.underlying < $1.underlying }

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
