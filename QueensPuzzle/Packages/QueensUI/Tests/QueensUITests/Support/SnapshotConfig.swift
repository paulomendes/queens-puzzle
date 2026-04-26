import SnapshotTesting
import Testing

extension Trait where Self == _SnapshotsTestTrait {
    static var snapshots: Self {
        .snapshots(diffTool: .ksdiff)
    }
}
