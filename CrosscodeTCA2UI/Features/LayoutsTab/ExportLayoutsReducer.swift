import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary

    @Reducer
struct ExportLayoutsReducer {
    @Dependency(\.apiClient) var apiClient
    
    enum Action: Equatable {
        case start
        case delegate(Delegate)
        case success

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
        let layouts = state.layouts.elements
        return .run { send in
            do {
                try await apiClient.layoutsAPI.exportLayouts(layouts:layouts)
                
                await send(.success)
            }
            catch {
                await send(.delegate(.failure(EquatableError(error))))
            }
        }
    }
}

