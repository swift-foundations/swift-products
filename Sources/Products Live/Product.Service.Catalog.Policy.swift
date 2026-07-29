import Products

extension Product.Service.Catalog {
    enum Policy {}
}

extension Product.Service.Catalog.Policy {
    static let catalog: Product.Catalog = Product.Catalog.default
}
