import CrosscodeDataLibrary

protocol LevelState {
    associatedtype ConcreteLevel: Level
    
    var isBusy: Bool {
        get set
    }
    var level: ConcreteLevel?{
        get set
    }
    
    var isDirty: Bool {
        get set
    }
}
