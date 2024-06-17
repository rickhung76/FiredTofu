import Foundation

protocol NetworkRouter: class {
    func send<T:Request>(_ route: T, decisions: [Decision]?, completion: @escaping (Result<T.Response,Error>)->())
    func cancel()
}
