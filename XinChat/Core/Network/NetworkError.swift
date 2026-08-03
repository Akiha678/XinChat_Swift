import Foundation

/// 网络层对外暴露的统一错误类型，避免业务层依赖 Alamofire 的具体错误。
enum NetworkError: LocalizedError {
    /// 响应对象或响应内容不符合预期。
    case invalidResponse
    /// 服务端返回非成功状态码。
    case server(statusCode: Int)
    /// 响应数据无法解析为目标模型。
    case decoding(Error)
    /// 超时、断网、DNS 等传输错误。
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
