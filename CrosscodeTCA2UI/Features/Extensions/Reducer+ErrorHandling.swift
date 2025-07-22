import ComposableArchitecture

// MARK: - Reducer Extensions
extension Reducer where State: ErrorHandling {
    func handleChildFailure<Child: CasePathable>(
        _ state: inout State,
        _ action: Child,
        errorCase: CaseKeyPath<Child, Error>,
        onFailure: ((Error, inout State) -> Void)? = nil
    ) -> Effect<Action> {
        guard let error = action[case: errorCase] else { return .none }
        return handleError(&state, error: error, onFailure: onFailure)
    }
    
    func handleChildDelegate<Child: CasePathable, Success>(
        _ state: inout State,
        _ action: Child,
        successCase: CaseKeyPath<Child, Success>,
        failureCase: CaseKeyPath<Child, Error>,
        onFailure: ((Error, inout State) -> Void)? = nil,
        onSuccess: (Success, inout State) -> Effect<Action>
    ) -> Effect<Action> {
        if let success = action[case: successCase] {
            return onSuccess(success, &state)
        }
        
        if let error = action[case: failureCase] {
            return handleError(&state, error: error, onFailure: onFailure)
        }
        
        return .none
    }
    
    func handleError(_ state: inout State, error: Error,
                     onFailure: ((Error, inout State) -> Void)? = nil) -> Effect<Action> {
        if let onFailure {
            onFailure(error, &state)
        }
        state.error = EquatableError(error)
        state.isBusy = false
        return .none
    }
}

// MARK: - Error Handling Protocol
protocol ErrorHandling {
    var error: EquatableError? { get set }
    var isBusy: Bool { get set }
}

