import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary

@Reducer
struct CreateGameLevelReducer {
    @Dependency(\.apiClient) var apiClient
    
    @CasePathable
    enum Action {
        
        case api(API)
        case `internal`(Internal)
        case delegate(Delegate)
        
        @CasePathable
        enum API {
            case start
        }
        
        @CasePathable
        enum Internal {
            case success
        }

        @CasePathable
        enum Delegate {
            case success
            case failure(Error)
        }
    }
    
    var body: some Reducer<EditLayoutFeature.State, Action> {
      
        Reduce { state, action in
            switch action {
                case let .api(apiAction):
                    switch apiAction {
                        case .start:
                            if !state.isPopulated { // Don't bother trying to save if not populated
                                return .run {  send in
                                    await send(.delegate(.success))
                                }
                            }
                            state.isBusy = true
                            
                            return addLevel(&state)
                    }
                    
                case let .internal(internalAction):
                    switch internalAction {
                        case .success:
                            state.isBusy = false
                            return .run {  send in
                                await send(.delegate(.success))
                            }
                    }

                case .delegate:
                    return .none
            }
        }
    }
    
    private func addLevel(_ state: inout EditLayoutFeature.State) -> Effect<Action> {
        let layout = state.layout
        
        return .run {  send in
            do {
                guard let layout = layout else { throw EditLayoutError.saveLayoutError("No layout found in add level") }
                
                try await apiClient.gameLevelsAPI.addNewLevel(layout: layout)
                
                await send(.internal(.success))
            }
            catch {
                await send(.delegate(.failure(error)))
            }
        }
    }
}
