import Dependencies
import CrosscodeDataLibrary

struct APIClient {
    var layoutsAPI: LayoutsAPI
    var gameLevelsAPI: GameLevelsAPI
}

extension APIClient: DependencyKey {
    static let liveValue = Self(
        layoutsAPI:LayoutsAPIImpl(),
        gameLevelsAPI: GameLevelsAPIImpl()
        
    )
    
    static let mock = Self (
        layoutsAPI: MockLayoutsAPI(levels: [Layout.mock]),
        gameLevelsAPI: MockGameLevelsAPI(/*levels: GameLevel.mocks*/)
    )
}




