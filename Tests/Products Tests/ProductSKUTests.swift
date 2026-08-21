import Dependencies
import Dependencies_Test_Support
import Foundation
import Testing

@testable import Products

@Suite("Product SKU Tests")
struct ProductSKUTests {

    @Test("SKU creation with no addons")
    func skuCreationNoAddons() {
        let sku = Product.SKU(tier: .daily, addons: [])

        #expect(sku.tier == .daily)
        #expect(sku.addons.isEmpty)
        #expect(sku.id.underlying == "daily")
    }

    @Test("SKU creation with addons")
    func skuCreationWithAddons() {
        let sku = Product.SKU(tier: .hourly, addons: [.analytics])

        #expect(sku.tier == .hourly)
        #expect(sku.addons == [.analytics])

        #expect(sku.id.underlying == "hourly:analytics")
    }

    @Test("SKU addons are sorted for consistent ID")
    func skuAddonsSorting() {

        let sku1 = Product.SKU(tier: .daily, addons: [.teamAccess, .analytics])
        let sku2 = Product.SKU(tier: .daily, addons: [.analytics, .teamAccess])

        #expect(sku1.id == sku2.id)
        #expect(sku1.addons == sku2.addons)
    }

    @Test("SKU equality")
    func skuEquality() {
        let sku1 = Product.SKU(tier: .daily, addons: [.analytics])
        let sku2 = Product.SKU(tier: .daily, addons: [.analytics])
        let sku3 = Product.SKU(tier: .hourly, addons: [.analytics])

        #expect(sku1 == sku2)
        #expect(sku1 != sku3)
    }

    @Test("Default catalog preserves the published product inventory")
    func defaultCatalogPreservesPublishedInventory() {
        let catalog = Product.Catalog.default

        #expect(catalog.tiers.map { $0.id } == [.weekly, .daily, .hourly])
        #expect(catalog.addons.map { $0.id } == [.analytics])
        #expect(
            catalog.availablePlans == [
                .weekly,
                .daily,
                .hourly,
                .dailyWithAnalytics,
                .hourlyWithAnalytics,
                .weeklyWithAnalytics,
            ]
        )
    }

    @Test("Catalog validation and capabilities preserve tier and addon policy")
    func catalogValidationAndCapabilitiesPreservePolicy() {
        let catalog = Product.Catalog.default
        let supportedPlan = Product.Plan.dailyWithAnalytics
        let unavailableAddonPlan = Product.Plan(
            tier: .daily,
            addons: [Product.Addon.ID.customAlerts]
        )

        #expect(catalog.isValidPlan(supportedPlan))
        #expect(
            supportedPlan.capabilities(from: catalog) == [
                .basicAnalytics,
                .csvExport,
                .advancedAnalytics,
                .apiAccess,
            ]
        )
        #expect(!catalog.isValidPlan(unavailableAddonPlan))
    }

    @Test("Capability resolution preserves missing catalog entry behavior")
    func capabilityResolutionPreservesMissingCatalogEntryBehavior() {
        let catalog = Product.Catalog(
            tiers: [],
            addons: [.analytics],
            availablePlans: []
        )
        let plan = Product.Plan(
            tier: .daily,
            addons: [.analytics, .customAlerts]
        )

        #expect(
            plan.capabilities(from: catalog) == [
                .advancedAnalytics,
                .apiAccess,
            ]
        )
    }

    @Test("Capability transport values and Set facade remain stable")
    func capabilityTransportValuesAndSetFacadeRemainStable() throws {
        let encoded = try JSONEncoder().encode(Product.Capability.apiAccess)
        let decoded = try JSONDecoder().decode(
            Set<Product.Capability>.self,
            from: Data(#"["api_access","csv_export"]"#.utf8)
        )

        #expect(String(bytes: encoded, encoding: .utf8) == #""api_access""#)
        #expect(decoded == [.apiAccess, .csvExport])
    }
}
