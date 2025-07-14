import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary


@Reducer
struct AddLayoutReducer<L: Reducer> {
    @Dependency(\.apiClient) var apiClient
    
    @CasePathable
    enum Action: Equatable {
        case start(String? = nil)
        case delegate(Delegate)
        
        @CasePathable
        enum Delegate : Equatable {
            case failure(EquatableError)
            case success
        }
    }
    
    var body: some Reducer<L.State, Action> {
//    var body: some Reducer<LayoutsTabFeature.State, Action> {
        Reduce { state, action in
            switch action {
                case let .start(layoutText):
                    return addLayout(&state, layoutText: layoutText)
                case .delegate:
                    return .none
            }
        }
    }
//    private func addLayout(_ state: inout LayoutsTabFeature.State) -> Effect<Action> {
    private func addLayout(_ state: inout L.State, layoutText: String?) -> Effect<Action> {
        return .run { send in
            do {
                try await apiClient.layoutsAPI.addNewLayout(crosswordLayout: layoutText)
                
                await send(.delegate(.success))
            }
            catch {
                await send(.delegate(.failure(EquatableError(error))))
            }
        }
    }
}

