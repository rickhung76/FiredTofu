import Foundation

protocol SessionTaskProgressDelegate: AnyObject {
    func sessionTask(_ request: RequestUnique, with updateProgress: Double)
}

protocol ProgressUpdatable: AnyObject {
    var delegate: SessionTaskProgressDelegate? { get set }
}
