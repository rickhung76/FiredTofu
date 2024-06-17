import Foundation


extension JSONDecoder {
    
    func decodeIfPresent<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
        
        do {
            let value = try decode(type, from: data)
            return value
        } catch {
            /// This is a hack move to decode while the generics type is Nil type
			/// DO NOT FIX IT THE WARNING !!!
            if let nil_T = Optional<T>.none as? T {
                return nil_T
            } else {
                throw APIError(.unableToDecode)
            }
        }
    }
}
