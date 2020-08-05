import Foundation
import FBSnapshotTestCase
import Utility

private var isCorrectSimulator: Bool = {
    #if targetEnvironment(simulator)
        let DEVICE_IS_SIMULATOR = true
    #else
        let DEVICE_IS_SIMULATOR = false
    #endif
    guard DEVICE_IS_SIMULATOR, let simVersion = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] else {
        return false
    }
    return simVersion == "iPhone12,3"
}()

class FBSnapshotBase: FBSnapshotTestCase {
    static let simVersion = ProcessInfo().environment
    
    override func setUp() {
        super.setUp()
        Swift.assert(isCorrectSimulator, "No Snapshots for you - Bad simulator. Use iPhone 11 Pro Simulator")
        if let appName = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String {
            folderName = "\(appName)/\(classForCoder)"
        }
    }
}
