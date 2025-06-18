import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary

@Reducer
struct SaveLayoutReducer {
    @Dependency(\.apiClient) var apiClient
    
    enum Action: Equatable {
        case start
        case success
        case failure(EquatableError)
    }
    
    var body: some Reducer<EditLayoutFeature.State, Action> {
        Reduce { state, action in
            switch action {
                case .start:
                    state.isBusy = true
                    if state.isPopulated {
                        return addLevel(&state)
                    }
                    return saveLayout(&state)
                    
                case .success:
                    state.isBusy = false
                    return .none
                    
                case .failure(let error):
                    state.isBusy = false
                    debugPrint(error)
                    return .none
            }
        }
    }
    
    private func saveLayout(_ state: inout EditLayoutFeature.State) -> Effect<Action> {
        let layout = state.layout
        
        return .run {  send in
            do {
                guard let layout = layout else { throw EditLayoutError.saveLayoutError("No layout found in save level") }
                
                try await apiClient.layoutsAPI.saveLevel(level: layout)
                
                await send(.success)
            }
            catch {
                await send(.failure(EquatableError(error)))
            }
        }
    }
    
    private func addLevel(_ state: inout EditLayoutFeature.State) -> Effect<Action> {
        let layout = state.layout
        
        return .run {  send in
            do {
                guard let layout = layout else { throw EquatableError(EditLayoutError.saveLayoutError("No layout found in add level")) }
                
                try await apiClient.gameLevelsAPI.addNewLevel(layout: layout)
                
                await send(.success)
            }
            catch {
                await send(.failure(EquatableError(error)))
            }
        }
    }
}
