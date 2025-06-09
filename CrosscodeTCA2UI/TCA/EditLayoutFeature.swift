import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary

@Reducer
struct EditLayoutFeature {
    @Dependency(\.uuid) var uuid
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.isPresented) var isPresented

    @ObservableState
    struct State: Equatable {
        var layoutID: UUID
        var layout: Layout?
        var isBusy = false
        var isPopulated: Bool = false
        var error: EquatableError?
    }

    enum Action: Equatable {
        case pageLoaded
        case loadLayout(LoadLayout)
        case backButtonTapped

        enum LoadLayout: Equatable {
            case start(UUID)
            case success(Layout)
            case failure(EquatableError)
        }


    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
                case .backButtonTapped:
                    if isPresented {
                        return .run { _ in await dismiss() }
                    } else {
                        return .none
                    }
                case .pageLoaded:
                    return .send(.loadLayout(.start(state.layoutID)))
                case .loadLayout(let subAction):
                    return handleLoadLayout(&state, action: subAction)
            }
        }
    }
}


extension EditLayoutFeature {
    private func handleLoadLayout(_ state: inout State, action:Action.LoadLayout) -> Effect<Action> {
        switch action {
            case .start(let id):
                return loadLayout(&state, id:id)
                
            case .success(let layout):
                state.layout = layout
                return .none
                
            case .failure(let error):
                debugPrint("Error: \(error)")
                return .none
        }
    }
    
    private func loadLayout(_ state: inout State, id:UUID) -> Effect<Action> {
        @Dependency(\.apiClient) var apiClient
        return .run { send in
            do {
                let result = try await apiClient.layoutsAPI.fetchLevel(id: id) as! Layout

                await send(.loadLayout(.success(result)))
            }
            catch let error as EquatableError {
                await send(.loadLayout(.failure(error)))
            }
            catch {
                await send(.loadLayout(.failure(EquatableError(error)))) // Fallback
            }
        }
    }
}





//        enum Cell: ActionNamespace {
//            static var select = action("Select", payload: UUID?.self)
//        }
//
//        enum Populate: ActionNamespace {
//            static var start = action("Start", payload: Crossword.self)
//            static var success = action("Success", payload: PopulationPayload.self)
//            static var failure = action("Failure", payload: Error.self)
//        }
//
//        enum CancelPopulation: ActionNamespace {
//            static var start = action("Cancel", payload: Crossword.self)
//            static var success = action("Success")
//        }
//
//        enum Depopulate: ActionNamespace {
//            static var start = action("Cancel", payload: Crossword.self)
//            static var success = action("Success", payload: PopulationPayload.self)
//        }
//
//        enum SaveLayout: ActionNamespace {
//            static var start = action("Cancel", payload: LevelLayout.self)
//            static var success = action("Success")
//            static var failure = action("Failure", payload: Error.self)
//
//        }
//
//        enum ExportPopulatedLevel: ActionNamespace {
//            static var start = action("Cancel", payload: LevelLayout.self)
//            static var success = action("Success")
//            static var failure = action("Failure", payload: Error.self)
//        }
