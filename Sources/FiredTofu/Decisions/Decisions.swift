import Foundation

open class Decisions {
    
    static let normalQueue = DispatchQueue(label: "normalQueue")
    static let priorityQueue = DispatchQueue(label: "priorityQueue", qos: .userInteractive)
    
    class func defaults(
		urlSession: URLSession,
		refreshTokenDecision: RefreshTokenDecision? = nil
	) -> [Decision] {
		let decisions: [Decision?] = [
            BuildRequestDecision(),
            SendRequestDecision(session: urlSession),
            RetryDecision(retryCount: 3, session: urlSession),
			refreshTokenDecision,
            BadResponseStatusCodeDecision(),
            ParseResultDecision()
		]
		return decisions.compactMap({$0})
    }
    
	class func refreshToken(session: URLSession) -> [Decision] {
        return [
            BuildRequestDecision(),
            SendRequestDecision(session: session, isPriority: true),
            RetryDecision(retryCount: 3, session: session, isPriority: true),
            BadResponseStatusCodeDecision(),
            ParseResultDecision()
        ]
    }
}




