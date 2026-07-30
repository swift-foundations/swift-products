extension Product {
    /// Concrete entitlements derived from tier + addons
    /// This replaces the simple Set<Capability> with actual values
    public struct Entitlements: Sendable, Codable, Equatable {
        public let refreshInterval: Duration
        public let exportFormats: Set<ExportFormat>
        public let apiAccess: Bool
        public let advancedAnalytics: Bool

        public init(
            refreshInterval: Duration,
            exportFormats: Set<ExportFormat> = [.json],
            apiAccess: Bool = false,
            advancedAnalytics: Bool = false
        ) {
            self.refreshInterval = refreshInterval
            self.exportFormats = exportFormats
            self.apiAccess = apiAccess
            self.advancedAnalytics = advancedAnalytics
        }

        /// Derive entitlements from a plan using the catalog
        public static func from(plan: Plan, catalog: Catalog) -> Entitlements? {
            guard let tier = catalog.getTier(plan.tier) else { return nil }

            let refreshInterval = tier.refreshRate.interval
            var exportFormats: Set<ExportFormat> = [.json]
            var apiAccess = false
            var advancedAnalytics = false

            // Base tier capabilities
            if tier.baseCapabilities.contains(.csvExport) {
                exportFormats.insert(.csv)
            }
            if tier.baseCapabilities.contains(.excelExport) {
                exportFormats.insert(.excel)
            }
            if tier.baseCapabilities.contains(.pdfExport) {
                exportFormats.insert(.pdf)
            }

            // Addon capabilities
            for addonId in plan.addons {
                guard let addon = catalog.getAddon(addonId) else { continue }

                if addon.capabilities.contains(.apiAccess) {
                    apiAccess = true
                }
                if addon.capabilities.contains(.advancedAnalytics) {
                    advancedAnalytics = true
                }
            }

            return Entitlements(
                refreshInterval: refreshInterval,
                exportFormats: exportFormats,
                apiAccess: apiAccess,
                advancedAnalytics: advancedAnalytics
            )
        }
    }

    public enum ExportFormat: String, Codable, Sendable, CaseIterable {
        case json
        case csv
        case excel
        case pdf
    }
}
