import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary


@Reducer
struct AddLayoutReducer<L: Reducer> {
    typealias State = L.State
    @Dependency(\.apiClient) var apiClient
    
    @CasePathable
    enum Action {
        
        case api(API)
        case delegate(Delegate)
        
        @CasePathable
        enum API {
            case start(String? = nil)
        }
        
        @CasePathable
        enum Delegate {
            case failure(Error)
            case success
        }
    }
    
    var body: some Reducer<L.State, Action> {
        Reduce { state, action in
            switch action {
                case let .api(apiAction):
                    return handleAPIAction(&state, apiAction)
                case .delegate:
                    return .none
            }
        }
    }
    
    private func addLayout(_ state: inout L.State, layoutText: String?) -> Effect<Action> {
        return .run { send in
            do {
                try await apiClient.layoutsAPI.addNewLayout(crosswordLayout: layoutText)
                
                await send(.delegate(.success))
            }
            catch {
                await send(.delegate(.failure(error)))
            }
        }
    }
}

private extension AddLayoutReducer {
    // MARK: View Actions
    func handleAPIAction(_ state: inout L.State, _ action: Action.API) -> Effect<Action> {
        switch action {
            case let .start(layoutText):
                return addLayout(&state, layoutText: layoutText)
        }
    }
}


