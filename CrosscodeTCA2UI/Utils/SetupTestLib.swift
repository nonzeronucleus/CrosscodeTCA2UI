import CrosscodeDataLibrary
import Factory

func setupTestLib(_ testName: String) {
    let _ = Container.shared.uuid
        .register { IncrementingUUIDProvider() }
    
//    debugPrint("Starting test \(testName)...")
}

func tearDownTestLib(_ testName: String) {
//    debugPrint("Stopping test \(testName)...")

    //    Container.shared.manager.pop()
}


