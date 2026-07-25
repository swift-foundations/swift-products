//
//  Products+Live.swift
//  swift-products
//
//  Created by Coen ten Thije Boonkkamp on 18/09/2025.
//

public import Dependencies
public import Products

extension ProductsService: Dependency.Key {
    public static var liveValue: Self {
        .init(
            client: .liveValue
        )
    }
}

extension ProductsService.Client: Dependency.Key {
    public static var liveValue: Self {
        let catalog = ProductsService.Catalog.Policy.catalog

        return .init(
            catalog: {
                catalog
            },
            validate: { plan in
                ProductsService.Plan.Policy.valid(plan, in: catalog)
            },
            capabilities: { plan in
                ProductsService.Plan.Policy.capabilities(for: plan, in: catalog)
            }
        )
    }
}
