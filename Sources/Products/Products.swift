public import Dependencies

// NOTE (works-first rename, run-arc 2026-07-12): this DI facade was named `Products`,
// which shadowed the module name `Products` and made `Products.Product` (module-qualified
// domain type) unresolvable. The domain `Product` collides with `Product_Primitives.Product`
// (a variadic-tuple type leaked transitively via parser/tagged primitives), so callers that
// see both must module-qualify as `Products.Product` — impossible while this struct shadowed
// the module. Renamed to `ProductsService` to free the module qualifier.
// PARKED durable alternative (morning ⚑, do NOT act tonight): keep the app `Product` name and
// stop `Product_Primitives.Product` from leaking into the app graph (namespace it under a nest
// per [API-NAME-001] in product-primitives, out of app zone), after which this rename reverts.
public struct ProductsService: @unchecked Sendable {
    public var client: Client

    public init(client: Client) {
        self.client = client
    }
}

extension ProductsService {
    @Witness
    public struct Client: Sendable {
        public var catalog: @Sendable () async throws -> Product.Catalog

        public var validate: @Sendable (_ plan: Product.Plan) async throws -> Bool

        public var capabilities:
            @Sendable (_ plan: Product.Plan) async throws -> Set<Product.Capability>
    }
}

extension ProductsService.Client: Dependency.Key.Test {
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
    public var products: ProductsService {
        get { self[ProductsService.self] }
        set { self[ProductsService.self] = newValue }
    }
}

extension ProductsService: Dependency.Key.Test {
    public static var testValue: Self {
        Self(client: .testValue)
    }
}
