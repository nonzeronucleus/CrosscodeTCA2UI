import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary

@Reducer
struct ExportGameLevelsReducer {
    @Dependency(\.apiClient) var apiClient
    
    enum Action: Equatable {
        case start
        case delegate(Delegate)
        case success

        enum Delegate : Equatable {
            case failure(EquatableError)
        }
    }
    
    var body: some Reducer<GameLevelsTabFeature.State, Action> {
        Reduce { state, action in
            switch action {
                case .start:
                    return exportGameLevels(&state)
                case .success:
                    return .none
                case .delegate:
                    return .none
            }
        }
    }
    private func exportGameLevels(_ state: inout GameLevelsTabFeature.State) -> Effect<Action> {
        return .run { send in
            do {
                try await apiClient.gameLevelsAPI.exportGameLevels()
                
                await send(.success)
            }
            catch {
                await send(.delegate(.failure(EquatableError(error))))
            }
        }
    }
}

