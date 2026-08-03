import Alamofire

protocol APIEndpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: Parameters? { get }
}

enum ChatAPI {
    case contacts
}

extension ChatAPI: APIEndpoint {
    var path: String {
        switch self {
        case .contacts: "/users"
        }
    }

    var method: HTTPMethod { .get }
    var parameters: Parameters? { nil }
}
