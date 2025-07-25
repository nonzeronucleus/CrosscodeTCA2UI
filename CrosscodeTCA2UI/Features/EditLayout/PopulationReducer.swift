import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary
import Factory

@Reducer
struct PopulationReducer {
    typealias State = EditLayoutFeature.State
    
    @Dependency(\.apiClient) var apiClient
    @Injected(\.uuid) var uuid
    
    
    @CasePathable
    enum Action {
        case api(API)
        case `internal`(Internal)
        case delegate(Delegate)
        
        @CasePathable
        enum API {
            case start
            case cancel
        }
        
        @CasePathable
        enum Internal {
            case finished(Result<(String, String), Error>)
        }
        
        @CasePathable
        enum Delegate {
            case finished(Result<(String, String), Error>)
        }
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
                case .api(.start):
                    state.isBusy = true
                    return .run { [state] send in
                        let result = await populate(state)
                        
                        switch result {
                            case .success(let (layoutText, charIntMap)):
                                await send(.internal(.finished(.success((layoutText, charIntMap)))))

                            case .failure(let error):
                                await send(.internal(.finished(.failure(error))))
                                
                        }
                    }
                    

                case .api(.cancel):
                    state.isBusy = false
                    return .run { send in
                        await apiClient.layoutsAPI.cancelPopulation()
                    }
                    
                case .internal(.finished(.success(let (layoutText, charIntMap)))):
                    state.isBusy = false
                    state.layout?.crossword = Crossword(initString:layoutText)
                    state.layout?.letterMap = CharacterIntMap(from: charIntMap)

                    return .run { send in await send(.delegate(.finished(.success((layoutText, charIntMap))))) }
                    
                case .internal(.finished(.failure(let error))):
                    state.isBusy = false
                    return .run { send in await send(.delegate(.finished(.failure(error)))) }
                    
                case .delegate:
                    return .none
            }
        }
    }
    
    func populate(_ state: State) async -> Result<(String, String), Error> {
        do {
            guard let layout = state.layout else {
                return .failure(EditLayoutError.handlePopulationError("No layout loaded"))
            }
            
            do {
                guard let populatedLevel = layout.gridText else {
                    throw EditLayoutError.handlePopulationError("No populated layout")
                }
                
                return try await .success(apiClient.layoutsAPI.populateCrossword(crosswordLayout: populatedLevel))
            } catch {
                return .failure(error)
            }
        }
    }
}
