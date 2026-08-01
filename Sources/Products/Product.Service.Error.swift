public import Witnesses

extension Product.Service {
    /// The failure domain for `Product.Service.Client` operations (`catalog`,
    /// `validate`, `capabilities`).
    ///
    /// No domain failure today: every current witness (`testValue`, `liveValue`)
    /// resolves in-memory against a static `Product.Catalog` and cannot fail; the
    /// only case is the `@Witness` unimplemented placeholder. The type exists
    /// so the throwing shape of the client interface is typed ([API-ERR-001]) and so
    /// a future witness backed by network or disk I/O can add a case without a
    /// source-breaking signature change to `Product.Service.Client`.
    public enum Error: Swift.Error, Sendable {
        /// Carries the diagnostic of an `@Witness`-generated `unimplemented()`
        /// placeholder, so a leaf-typed operation throws rather than trapping.
        case notImplemented(Witness.Unimplemented.Error)
    }
}

extension Product.Service.Error: Witness.Unimplemented.Representable {
    public static func unimplemented(_ error: Witness.Unimplemented.Error) -> Self {
        .notImplemented(error)
    }
}
