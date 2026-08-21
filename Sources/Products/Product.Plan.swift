import Dependencies
import Entitlement
import Foundation
public import Tagged_Primitives

extension Product {
    // Plan represents a combination of a tier and optional addons
    public struct Plan: Sendable, Codable, Hashable {
        public let tier: Tier.ID
        public let addons: Set<Addon.ID>

        public init(
            tier: Tier.ID,
            addons: some Swift.Sequence<Addon.ID> = []
        ) {
            self.tier = tier
            self.addons = Set(addons)
        }

        /// Convert to stable SKU for billing/Stripe
        public var sku: SKU {
            SKU(from: self)
        }

        /// Validate business rules
        public func isValid() -> Bool {
            // Weekly tier now supports addons as a $0 subscription
            // All tiers can have addons
            return true
        }
    }
}

extension Product.Plan {
    public static let weekly: Self = .init(tier: .weekly)
    public static let daily: Self = .init(tier: .daily)
    public static let hourly: Self = .init(tier: .hourly)
    public static let weeklyWithAnalytics: Self = .init(tier: .weekly, addons: [.analytics])
    public static let dailyWithAnalytics: Self = .init(tier: .daily, addons: [.analytics])
    public static let hourlyWithAnalytics: Self = .init(tier: .hourly, addons: [.analytics])

    // Helper to get all capabilities from tier and addons
    public func capabilities(from catalog: Product.Catalog) -> Set<Product.Capability> {
        var rules: [Entitlement.Rule<Product.Capability, Date, Product.Plan>] = []

        if let tier = catalog.tiers.first(where: { $0.id == self.tier }) {
            rules.append(
                contentsOf: tier.baseCapabilities.map {
                    .init(
                        capability: $0,
                        effect: .grant,
                        expiration: nil,
                        priority: .base,
                        source: self
                    )
                }
            )
        }

        for addonID in addons {
            if let addon = catalog.addons.first(where: { $0.id == addonID }) {
                rules.append(
                    contentsOf: addon.capabilities.map {
                        .init(
                            capability: $0,
                            effect: .grant,
                            expiration: nil,
                            priority: .base,
                            source: self
                        )
                    }
                )
            }
        }

        let policy = Entitlement.Policy(rules: rules)
        let instant = Date.now
        return Set(
            rules.lazy
                .map(\.capability)
                .filter { policy.decision(for: $0, at: instant).effect == .grant }
        )
    }
}
