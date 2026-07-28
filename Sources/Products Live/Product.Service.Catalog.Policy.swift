import Products

extension ProductsService.Catalog {
    enum Policy {}
}

extension ProductsService.Catalog.Policy {
    static let catalog: Product.Catalog = Product.Catalog.default
}
