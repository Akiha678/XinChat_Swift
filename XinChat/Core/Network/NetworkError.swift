import Foundation

enum NetworkError: LocalizedError {
    case invalidResponse
    case server(statusCode: Int)
    case decoding(Error)
    case transport(Error)

    var errorDescription: String? {
        switch self {
        case .invalidResponse: "服务器响应无效"
        case let .server(code): "服务暂时不可用（\(code)）"
        case .decoding: "数据解析失败"
        case let .transport(error): error.localizedDescription
        }
    }
}
