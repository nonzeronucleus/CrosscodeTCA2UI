class EquatableError: Error, Equatable {
    let wrappedError: Error
    
    init(_ error: Error) {
        self.wrappedError = error
    }
    
    static func == (lhs: EquatableError, rhs: EquatableError) -> Bool {
        return lhs.wrappedError.localizedDescription == rhs.wrappedError.localizedDescription
    }
    
    var localizedDescription: String {
        return wrappedError.localizedDescription
    }
    
    var description: String {
        return wrappedError.localizedDescription
    }
}


