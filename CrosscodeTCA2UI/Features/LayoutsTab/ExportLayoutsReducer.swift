import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary

    @Reducer
struct ExportLayoutsReducer {
    @Dependency(\.apiClient) var apiClient
    
    @CasePathable
    enum Action: Equatable {
        case start
        case delegate(Delegate)
        case success

        @CasePathable
        enum Delegate : Equatable {
            case failure(EquatableError)
        }
    }
    
    var body: some Reducer<LayoutsTabFeature.State, Action> {
        Reduce { state, action in
            switch action {
                case .start:
                    return exportLayouts(&state)
                case .success:
                    return .none
                case .delegate:
                    return .none
            }
        }
    }
    private func exportLayouts(_ state: inout LayoutsTabFeature.State) -> Effect<Action> {
        return .run { send in
            do {
                try await apiClient.layoutsAPI.exportLayouts()
                
                await send(.success)
            }
            catch {
                await send(.delegate(.failure(EquatableError(error))))
            }
        }
    }
}

