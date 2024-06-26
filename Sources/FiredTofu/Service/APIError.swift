import Foundation

public enum APIErrorCode: Int {
    case badRequest 			= 40000
    case encodingFailed 		= 40001
    case missingURL 			= 40002
    case missingRequest 		= 40003
	case deprecatedRequest 		= 40004
    case authenticationError 	= 40100
    case invalidToken 			= 40300
    case missingResponse 		= 41000
    case missingData 			= 41001
    case unableToDecode 		= 42200
    case clientError 			= 49900
	case isNotReachability 		= 49901
    case serverError 			= 50000
    case unknownError 			= 77777

    
    public var description: String {
        switch self {
        case .badRequest:
            return "Bad request"
        case .encodingFailed:
            return "Parameter encoding failed."
        case .missingURL:
            return "URL is nil."
        case .missingRequest:
            return "Request is nil."
		case .deprecatedRequest:
			return "Request is deprecated"
        case .authenticationError:
            return "You need to be authenticated first."
        case .invalidToken:
            return "Invalid Token !"
        case .missingResponse:
            return "Response returned with no Http response."
        case .missingData:
            return "Response returned with no data to decode."
        case .unableToDecode:
            return "We could not decode the response."
        case .clientError:
            return "Client Error"
        case .serverError:
            return "Server Error"
        case .unknownError:
            return "Unknow Error"
        case .isNotReachability:
            return "没有网路连线"
        }
    }
}

public struct APIError: Error, LocalizedError {
	public let statusCode: Int
	public let message: String
	public let details: String?
    
    public init(_ code: Int, _ message: String, _ details: String? = nil) {
        self.statusCode = code
        self.message = message
        self.details = details
    }
    
    public init(_ apiErrorCode: APIErrorCode, _ details: String? = nil) {
        self.statusCode = apiErrorCode.rawValue
        self.message = apiErrorCode.description
        self.details = details
    }
    
    public var errorDescription: String? {
        return self.message
    }
}
