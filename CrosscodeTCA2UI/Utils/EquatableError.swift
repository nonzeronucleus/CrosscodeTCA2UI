class EquatableError: Error, Equatable {
    let error: Error
    
    init(_ error: Error) {
        self.error = error
    }
    
    static func == (lhs: EquatableError, rhs: EquatableError) -> Bool {
        return lhs.error.localizedDescription == rhs.error.localizedDescription
    }
}
