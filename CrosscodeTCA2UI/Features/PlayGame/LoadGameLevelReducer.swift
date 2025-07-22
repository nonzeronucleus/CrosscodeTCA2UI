import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary

@Reducer
struct LoadGameLevelReducer {
    @Dependency(\.apiClient) var apiClient
    
    @CasePathable
    enum Action: Equatable {
        case api(API)
        case `internal`(Internal)
        case delegate(Delegate)
        
        @CasePathable
        enum API: Equatable {
            case start(UUID)
        }
        
        @CasePathable
        enum Internal : Equatable  {
            case success(GameLevel)
        }
        
        @CasePathable
        enum Delegate : Equatable {
            case failure(EquatableError)
        }
    }
    
    var body: some Reducer<PlayGameFeature.State, Action> {
        Reduce { state, action in
            switch action {
                case let .api(externalActions):
                    switch externalActions {
                        case .start(let id):
                            state.isBusy = true
                            return loadLevel(&state, id:id)
                    }


                case let .internal(internalAction):
                    switch internalAction {
                        case .success(let level):
                            state.level = level
                            state.isBusy = false
                            state.isDirty = false
                            
                            return .none
                    }
                    
                case .delegate:
                    return .none
            }
        }
    }
    
    private func loadLevel(_ state: inout PlayGameFeature.State, id:UUID) -> Effect<Action> {
        return .run { send in
            do {
                let result = try await apiClient.gameLevelsAPI.fetchLevel(id: id)
                
                if let result = result as? GameLevel {
                    await send(.internal(.success(result)))
                }
                else {
                    await send(.delegate(.failure(EquatableError(PlayGameFeature.FeatureError.loadLevelError))))
                }
            }
            catch {
                await send(.delegate(.failure(EquatableError(error))))
            }
        }
    }
}
