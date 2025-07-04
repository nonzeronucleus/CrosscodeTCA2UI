import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary

@Reducer
struct CreateGameLevelReducer {
    @Dependency(\.apiClient) var apiClient
    
    enum Action: Equatable {
        case start
        case delegate(Delegate)
        
        enum Delegate : Equatable {
            case success
            case failure(EquatableError)
        }
    }
    
    var body: some Reducer<EditLayoutFeature.State, Action> {
      
        Reduce { state, action in
            switch action {
                case .start:
                    if !state.isPopulated { // Don't bother trying to save if not populated
                        return .run {  send in
                            await send(.delegate(.success))
                        }
                    }
                    state.isBusy = true
                    
                    return addLevel(&state)
                    
                case .delegate:
                    return .none
            }
        }
    }
    
    private func addLevel(_ state: inout EditLayoutFeature.State) -> Effect<Action> {
        let layout = state.layout
        
        return .run {  send in
            do {
                guard let layout = layout else { throw EquatableError(EditLayoutError.saveLayoutError("No layout found in add level")) }
                
                try await apiClient.gameLevelsAPI.addNewLevel(layout: layout)
                
                await send(.delegate(.success))
            }
            catch {
                await send(.delegate(.failure(EquatableError(error))))
            }
        }
    }
}
