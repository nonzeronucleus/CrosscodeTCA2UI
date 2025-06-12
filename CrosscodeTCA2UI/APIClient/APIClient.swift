import Dependencies
import CrosscodeDataLibrary

struct APIClient {
    var layoutsAPI: LayoutsAPI
}

extension APIClient: DependencyKey {
    static let liveValue = Self(
      layoutsAPI:
//        MockLayoutsAPI(levels: [Layout.mock])
      LayoutsAPIImpl()
    )
    
    static let mock = Self (
        layoutsAPI: MockLayoutsAPI(levels: [Layout.mock])
    )
}




