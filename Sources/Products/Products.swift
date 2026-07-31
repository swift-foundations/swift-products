public import Dependencies

// NOTE (naming pass, 2026-07-28): this DI facade must NOT be named `Products` — that
// shadows the module name `Products` and makes `Products.Product` (the module-qualified
// domain type) unresolvable in consumers. The domain `Product` collides with
// `Product_Primitives.Product`, a variadic-tuple type legitimately re-exported by
// `swift-parser-primitives` (`public typealias Failure = Product<…>` in Parser.OneOf.*),
// so callers that see both MUST module-qualify as `Products.Product`. Nesting the facade
// under the domain type satisfies `Nest.Name` ([API-NAME-001]) without reclaiming the
// module qualifier. Verified 2026-07-28: naming this `Products` fails swift-pricing's
// build at the @Witness expansion in Pricing.swift.
extension Product {
    public struct Service: @unchecked Sendable {
        public var client: Client

        public init(client: Client) {
            self.client = client
        }
    }
}

extension Product.Service {
    @Witness
    public struct Client: Sendable {
        public var catalog: @Sendable () async throws(Product.Service.Error) -> Product.Catalog

        public var validate:
            @Sendable (_ plan: Product.Plan) async throws(Product.Service.Error) -> Bool

        public var capabilities:
            @Sendable (_ plan: Product.Plan) async throws(Product.Service.Error)
                -> Set<Product.Capability>
    }
}

extension Product.Service.Client: Dependency.Key.Test {
    public static var testValue: Self {
        Self(
            catalog: { Product.Catalog.default },
            validate: { Product.Catalog.default.isValidPlan($0) },
            capabilities: { $0.capabilities(from: Product.Catalog.default) }
        )
    }
}

// W-E2 DI ROOT (di-composition-root-design.md §4.5): the accessor lives HERE, in the
// interface module, and binds the Test-only subscript overload by design — the app's
// composition root registers the live value
// (explicit overrides resolve ahead of mode defaults), and an UNREGISTERED live-mode
// resolution fails loud, naming this key (§4.2 tripwire). Consumers import the
// interface, never the Live module. (Reverts the W-3 DI-ACCESSOR SWEEP relocation.)
extension Dependency.Values {
    public var products: Product.Service {
        get { self[Product.Service.self] }
        set { self[Product.Service.self] = newValue }
    }
}

extension Product.Service: Dependency.Key.Test {
    public static var testValue: Self {
        Self(client: .testValue)
    }
}
