//
//  Products+Live.swift
//  swift-products
//
//  Created by Coen ten Thije Boonkkamp on 18/09/2025.
//

public import Dependencies
public import Products

extension Product.Service: Dependency.Key {
    public static var liveValue: Self {
        .init(
            client: .liveValue
        )
    }
}

extension Product.Service.Client: Dependency.Key {
    public static var liveValue: Self {
        let catalog = Product.Service.Catalog.Policy.catalog

        return .init(
            catalog: {
                catalog
            },
            validate: { plan in
                Product.Service.Plan.Policy.valid(plan, in: catalog)
            },
            capabilities: { plan in
                Product.Service.Plan.Policy.capabilities(for: plan, in: catalog)
            }
        )
    }
}
