import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary
import Factory

@Reducer
struct SaveLevelReducer<R: Reducer> where R.State: LevelState {
    typealias State = R.State
    let levelAPI: LevelsAPI
    
//    @Dependency(\.apiClient) var apiClient
    @Injected(\.uuid) var uuid
    
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
            case finished(Result<Void, Error>)
        }
        
        @CasePathable
        enum Delegate {
            case finished(Result<Void, Error>)
        }
    }
    
    init(levelAPI: LevelsAPI) {
        self.levelAPI = levelAPI
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
                case .api(.start):
                    state.isBusy = true
                    return .run { [state] send in
                        let result = await saveLayout(state)
                        
                        await send(.internal(.finished(result)))
                    }
                        
                case .internal(.finished(.success)):
                    state.isBusy = false
                    state.isDirty = false
                    
                    return .run { send in await send(.delegate(.finished(.success(())))) }
                    
                case .internal(.finished(.failure(let error))):
                    state.isBusy = false
                    return .run { send in await send(.delegate(.finished(.failure(error)))) }
                    
                case .delegate:
                    return .none
            }
        }
    }

    private func saveLayout(_ state: State) async -> Result<Void, Error> {
        guard let layout = state.level else {
            return .failure(EditLayoutError.saveLayoutError("No layout found in save level"))
        }
        do {
//            try await apiClient.layoutsAPI.saveLevel(level: layout)
            try await levelAPI.saveLevel(level: layout)
            return .success(())
        } catch {
            return .failure(error)
        }
    }
}
