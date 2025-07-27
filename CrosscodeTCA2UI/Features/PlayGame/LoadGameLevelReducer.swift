import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary

@Reducer
struct LoadGameLevelReducer {
    @Dependency(\.apiClient) var apiClient
    
    @CasePathable
    enum Action {
        case api(API)
        case `internal`(Internal)
        case delegate(Delegate)
        
        @CasePathable
        enum API {
            case start(UUID)
        }
        
        @CasePathable
        enum Internal  {
            case finished(Result<GameLevel, Error>)
        }
        
        @CasePathable
        enum Delegate {
            case finished(Result<GameLevel, Error>)
        }
    }
    
    var body: some Reducer<PlayGameFeature.State, Action> {
        Reduce { state, action in
            switch action {
                case let .api(externalActions):
                    switch externalActions {
                        case .start(let id):
                            state.isBusy = true
                            return .run { send in
                                let result = await loadLevel(id: id, apiClient: apiClient)
                                await send(.internal(.finished(result)))
                            }
                    }
                    
                case .internal(.finished(let result)):
                    state.isBusy = false
                    switch result {
                        case .success(let level):
                            state.level = level
                            state.isDirty = false
                            
                        case .failure:
                            break
                    }
                    return .run { send in await send(.delegate(.finished(result))) }

                case .delegate:
                    return .none
            }
        }
    }
    
    func loadLevel(id: UUID, apiClient: APIClient) async -> Result<GameLevel, Error> {
        do {
            let result = try await apiClient.gameLevelsAPI.fetchLevel(id: id)
            guard let level = result as? GameLevel else {
                throw PlayGameFeature.FeatureError.loadLevelError
            }
            return .success(level)
        } catch {
            return .failure(error)
        }
    }
}
