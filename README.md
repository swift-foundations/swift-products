# swift-products

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

A product catalogue of tiers and add-ons composed into plans, where each plan collapses to a deterministic billing SKU and to the concrete entitlements it grants.

---

## Key Features

- **Order-free billing identity** — a plan's add-ons are an unordered `Set`, but `Product.SKU` sorts before joining, so the same tier and add-on set always produce the same identifier.
- **Tagged identifiers** — `Tier.ID`, `Addon.ID`, and `SKU.ID` are distinct phantom-typed `String` wrappers; passing a tier identifier where an add-on identifier belongs does not compile.
- **Capabilities resolve through a policy** — `Plan.capabilities(from:)` runs tier and add-on grants through an entitlement policy rather than unioning sets, so precedence and expiry are decided in one place.
- **Concrete entitlements, not capability flags** — `Product.Entitlements` carries a refresh `Duration`, an export-format set, and access booleans derived from the plan and catalogue together.
- **Catalogue-validated plans** — `Catalog.isValidPlan(_:)` and `isValidSKU(_:)` reject a plan naming a tier or add-on the catalogue does not contain.

---

## Installation

```swift
dependencies: [
    .package(
        url: "https://github.com/swift-foundations/swift-products.git",
        branch: "main"
    )
]
```

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "Products", package: "swift-products")
    ]
)
```

The package publishes no tags yet, so the dependency is pinned to `main`.

---

## Quick Start

```swift
import Products

// Module-qualified: the `Products` module's `Product` shares its name with a type
// re-exported through the primitives graph, so the qualifier is required at call sites
// that can see both.
// A plan's add-ons are an unordered Set, but its billing identity must not be.
let written = Products.Product.SKU(tier: .hourly, addons: [.analytics, .teamAccess])
let reordered = Products.Product.SKU(tier: .hourly, addons: [.teamAccess, .analytics])

print(written.id.underlying)      // "hourly:analytics+team"
print(written.id == reordered.id) // true

// Entitlements come from the tier and the add-ons together, not from either alone.
let plan = Products.Product.Plan(tier: .hourly, addons: [.analytics])
let catalogue = Products.Product.Catalog.default

print(catalogue.isValidPlan(plan))  // true

if let entitlements = Products.Product.Entitlements.from(plan: plan, catalog: catalogue) {
    print(entitlements.apiAccess)   // true — granted by the analytics add-on
    // exportFormats holds json, csv, excel and pdf: the hourly tier's export grants
    print(entitlements.exportFormats.count)  // 4
}
```

---

## Architecture

The package ships two products. The module name substitutes an underscore for the
space, so `Products Live` is imported as `Products_Live`.

| Product | When to import |
|---|---|
| `Products` | Any code that names a tier, add-on, plan, SKU, capability, or entitlement. Carries the whole model plus the `\.products` dependency accessor. |
| `Products Live` | The composition root only. Supplies `liveValue` for `ProductsService` and `ProductsService.Client`, bound to the built-in catalogue. |

The model splits into a value layer and a service layer. The value layer —
`Product.Tier`, `Product.Addon`, `Product.Plan`, `Product.SKU`, `Product.Catalog`,
`Product.Capability`, `Product.Entitlements` — is pure and needs no dependency
resolution; the examples above use it directly. The service layer, `ProductsService`,
wraps catalogue lookup, plan validation, and capability resolution behind a
struct of async closures for code that resolves them through dependency injection.

`ProductsService` is deliberately not named `Products`: the type would otherwise
shadow the module name and make the `Products.Product` qualifier above unwritable.

### The built-in catalogue

`Product.Catalog.default` is a concrete catalogue — three data-freshness tiers
(`weekly`, `daily`, `hourly`), one analytics add-on, and six pre-configured plans —
and it is what `Products Live` serves. It is a working catalogue rather than a
neutral template. The types are general; the shipped values are not. A consumer
with a different product line builds its own `Product.Catalog` and either passes it
directly to the value-layer calls or constructs its own `ProductsService.Client`.

Three further identities — the `realtime` tier and the `teamAccess` and
`customAlerts` add-ons — are declared but are not members of the default catalogue.

---

## Platform Support

| Platform | CI | Status |
|---|---|---|
| macOS 26+ | — | Supported |

The manifest additionally declares iOS, macCatalyst, tvOS, watchOS, and visionOS at
version 26. Those targets have not been built or tested here, so no status is
claimed for them. Continuous integration is configured but is not currently
passing, so no CI badge is shown.

---

## Related Packages

**Dependencies**

- [swift-tagged-primitives](https://github.com/swift-primitives/swift-tagged-primitives) — Phantom-typed value wrappers backing the tier, add-on, and SKU identifiers.
- swift-entitlement (private, unreleased) — Grant and deny decisions with expiry and override precedence, used by capability resolution.
- swift-dependencies (unreleased) — Dependency injection and the `\.products` accessor's resolution machinery.

**Used By**

- swift-pricing (private, unreleased) — Prices tiers and add-ons keyed on the identities declared here.

---

## Community

<!-- BEGIN: discussion -->
*Discussion thread will be created at first public flip.*
<!-- END: discussion -->

---

## License

Licensed under the [Apache License, Version 2.0](LICENSE.md).
