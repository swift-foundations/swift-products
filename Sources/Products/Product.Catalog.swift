import Dependencies
public import Tagged_Primitives

extension Product {

    public struct Catalog: Sendable, Codable {
        public let tiers: [Product.Tier]
        public let addons: [Product.Addon]
        public let availablePlans: [Product.Plan]

        public init(
            tiers: [Product.Tier],
            addons: [Product.Addon],
            availablePlans: [Product.Plan]
        ) {
            self.tiers = tiers
            self.addons = addons
            self.availablePlans = availablePlans
        }

        public static let `default` = Catalog(
            tiers: Tier.all,
            addons: Addon.all,
            availablePlans: [
                .weekly,
                .daily,
                .hourly,
                .dailyWithAnalytics,
                .hourlyWithAnalytics,
                .weeklyWithAnalytics,
            ]
        )

        public func isValidPlan(_ plan: Product.Plan) -> Bool {

            guard tiers.contains(where: { $0.id == plan.tier }) else { return false }

            for addonId in plan.addons {
                guard addons.contains(where: { $0.id == addonId }) else { return false }
            }

            return plan.isValid()
        }

        public var availableSKUs: [SKU] {
            availablePlans.compactMap { plan in
                isValidPlan(plan) ? plan.sku : nil
            }
        }

        public func isValidSKU(_ sku: SKU) -> Bool {
            let plan = Plan(tier: sku.tier, addons: Set(sku.addons))
            return isValidPlan(plan)
        }

        public func getTier(_ id: Tier.ID) -> Tier? {
            tiers.first { $0.id == id }
        }

        public func getAddon(_ id: Addon.ID) -> Addon? {
            addons.first { $0.id == id }
        }
    }
}
