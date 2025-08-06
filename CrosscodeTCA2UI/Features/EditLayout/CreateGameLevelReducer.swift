import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary



@Reducer
struct CreateGameLevelReducer {
    typealias State = EditLayoutFeature.State
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
        enum Delegate {
            case finished(Result<Void, Error>)
        }
        
        @CasePathable
        enum Internal {
            case finished(Result<Void, Error>)
        }
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
                case .api(.start):
                    state.isBusy = true

                    return .run { [state] send in
                        let result = await addLevel(state)
                        
                        switch result {
                            case .success:
                                await send(.internal(.finished(.success(()))))
                                
                            case .failure(let error):
                                await send(.internal(.finished(.failure(error))))
                                
                        }
                    }

                case .internal(.finished(.success)):
                    state.isBusy = false
                    return .run { send in await send(.delegate(.finished(.success((()))))) }
                    
                case .internal(.finished(.failure(let error))):
                    state.isBusy = false
                    return .run { send in await send(.delegate(.finished(.failure(error)))) }

                case .delegate(_):
                    return .none
            }
        }
    }
    
    func addLevel(_ state: State) async -> Result<(Void), Error> {
        let layout = state.level

        do {
            guard let layout = layout else { throw EditLayoutError.saveLayoutError("No layout found in add level") }

            try await apiClient.gameLevelsAPI.addNewLevel(layout: layout)

            return (.success(()))
        }
        catch {
           return .failure(error)
        }
    }
}
