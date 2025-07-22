import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary


@Reducer
struct LoadLayoutReducer {
    typealias State = EditLayoutFeature.State
    @Dependency(\.apiClient) var apiClient
    
    @CasePathable
    enum Action: Equatable {
        case api(API)
        case delegate(Delegate)

        @CasePathable
        enum API: Equatable {
            case start(UUID)
        }
        
        @CasePathable
        enum Delegate : Equatable {
            case finished(TaskResult<Layout>)
            case other
        }
        
        case `internal`(Internal)
        @CasePathable
        enum Internal: Equatable {
            case finished(TaskResult<Layout>)
        }
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
                case .api(.start(let id)):
                    state.isBusy = true
                    return .run { send in
                        let result = await TaskResult {
                            let response = try await apiClient.layoutsAPI.fetchLevel(id: id)
                            guard let layout = response as? Layout else {
                                throw EditLayoutError.loadLayoutError
                            }
                            return layout
                        }
                        await send(.internal(.finished(result)))
                        await send(.delegate(.finished(result)))
                    }
                    
                    
                case .internal(.finished(let result)):
                    state.isBusy = false
                    switch result {
                        case .success(let layout):
                            state.layout = layout
                        case .failure:
                            break
                    }
                    return .none
                    
                case .delegate:
                    return .none
            }
        }
    }
}
