import Dependencies
public import Tagged_Primitives

extension Product {
    // Catalog represents the available products
    public struct Catalog: Sendable, Codable {
        public let tiers: [Product.Tier]
        public let addons: [Product.Addon]
        public let availablePlans: [Product.Plan]  // Pre-configured valid plans

        public init(
            tiers: [Product.Tier],
            addons: [Product.Addon],
            availablePlans: [Product.Plan]
        ) {
            self.tiers = tiers
            self.addons = addons
            self.availablePlans = availablePlans
        }

        // Default catalog for the application
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

        // Validate if a plan is available and follows business rules
        public func isValidPlan(_ plan: Product.Plan) -> Bool {
            // Check tier exists
            guard tiers.contains(where: { $0.id == plan.tier }) else { return false }

            // Check all addons exist
            for addonId in plan.addons {
                guard addons.contains(where: { $0.id == addonId }) else { return false }
            }

            // Apply business rules
            return plan.isValid()
        }

        // Get all valid SKUs from available plans
        public var availableSKUs: [SKU] {
            availablePlans.compactMap { plan in
                isValidPlan(plan) ? plan.sku : nil
            }
        }

        // Check if a SKU is available
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
