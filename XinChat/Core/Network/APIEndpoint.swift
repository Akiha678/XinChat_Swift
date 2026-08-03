import Alamofire

/// 描述一次 API 请求所需的路径、方法和参数。
/// 新增接口时通过遵循该协议接入，无需修改底层 `NetworkClient`。
protocol APIEndpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: Parameters? { get }
}

/// 通讯模块当前使用的接口集合。
enum ChatAPI {
    /// 获取联系人列表。
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
