import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary

    @Reducer
struct ImportLayoutsReducer {
    @Dependency(\.apiClient) var apiClient
    
    enum Action: Equatable {
        case start
        case delegate(Delegate)
        case success([Layout])

        enum Delegate : Equatable {
            case failure(EquatableError)
        }
    }
    
    var body: some Reducer<LayoutsTabFeature.State, Action> {
        Reduce { state, action in
            switch action {
                case .start:
                    return importLayouts(&state)
                case let .success(layouts):
                    state.layouts = IdentifiedArrayOf(uniqueElements: layouts)
                    return .none
                case .delegate:
                    return .none
            }
        }
    }
    private func importLayouts(_ state: inout LayoutsTabFeature.State) -> Effect<Action> {
        return .run { send in
            do {
                let layouts = try await apiClient.layoutsAPI.importLayouts()

                await send(.success(layouts))
            }
            catch {
                await send(.delegate(.failure(EquatableError(error))))
            }
        }
    }
}

