extension Product.Service {
    /// The failure domain for `Product.Service.Client` operations (`catalog`,
    /// `validate`, `capabilities`).
    ///
    /// Uninhabited today: every current witness (`testValue`, `liveValue`) resolves
    /// in-memory against a static `Product.Catalog` and cannot fail. The type exists
    /// so the throwing shape of the client interface is typed ([API-ERR-001]) and so
    /// a future witness backed by network or disk I/O can add a case without a
    /// source-breaking signature change to `Product.Service.Client`.
    public enum Error: Swift.Error, Sendable {}
}
