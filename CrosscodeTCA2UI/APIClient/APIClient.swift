import Dependencies

struct APIClient {
    var layoutsAPI: LayoutsAPI
}

extension APIClient: DependencyKey {
    static let liveValue = Self(
      layoutsAPI: MockLayoutsAPI()
    )
    
    static let mock = Self (
        layoutsAPI: MockLayoutsAPI()
    )
}




