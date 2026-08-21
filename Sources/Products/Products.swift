public import Dependencies

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
