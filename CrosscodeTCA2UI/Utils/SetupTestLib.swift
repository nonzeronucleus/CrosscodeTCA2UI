import CrosscodeDataLibrary
import Factory

func setupTestLib(_ testName: String) {
    let _ = Container.shared.uuid
        .register { IncrementingUUIDProvider() }
}

func tearDownTestLib(_ testName: String) {
}


