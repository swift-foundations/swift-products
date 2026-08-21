public import Witnesses

extension Product.Service {

    public enum Error: Swift.Error, Sendable {

        case notImplemented(Witness.Unimplemented.Error)
    }
}

extension Product.Service.Error: Witness.Unimplemented.Representable {
    public static func unimplemented(_ error: Witness.Unimplemented.Error) -> Self {
        .notImplemented(error)
    }
}
