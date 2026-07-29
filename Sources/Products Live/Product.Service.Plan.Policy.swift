import Products

extension Product.Service.Plan {
    enum Policy {}
}

extension Product.Service.Plan.Policy {
    static func valid(_ plan: Product.Plan, in catalog: Product.Catalog) -> Bool {
        catalog.isValidPlan(plan)
    }

    static func capabilities(
        for plan: Product.Plan,
        in catalog: Product.Catalog
    ) -> Set<Product.Capability> {
        plan.capabilities(from: catalog)
    }
}
