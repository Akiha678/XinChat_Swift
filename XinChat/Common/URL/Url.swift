import Foundation

/// 服务器环境枚举，解耦存储 Key 与展示文案
enum ServerEnvironment: String, CaseIterable {
    case dev = "dev"
    case stag = "stag"
    case prod = "prod"

    /// UI 显示的友好名称
    var displayName: String {
        switch self {
        case .dev:  return "开发环境 (本地)"
        case .stag: return "测试环境 (内网)"
        case .prod: return "生产环境 (线上)"
        }
    }

    /// 各环境对应的基础服务器地址
    var baseURL: URL {
        switch self {
        case .dev:  return URL(string: "http://127.0.0.1:8080")!
        case .stag: return URL(string: "http://192.168.31.111:8080")!
        case .prod: return URL(string: "http://111.231.53.205:8080")!
        }
    }
}

/// 应用环境集中管理（支持多环境切换、持久化记忆与生产包强制锁定）
enum AppEnvironment {
    private static let environmentKey = "kAppServerEnvironmentKey"

    #if DEBUG
    /// 当前选中的服务器环境（开发模式下可动态修改并自动持久化）
    static var current: ServerEnvironment {
        get {
            guard let saved = UserDefaults.standard.string(forKey: environmentKey),
                  let env = ServerEnvironment(rawValue: saved) else {
                return .dev
            }
            return env
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: environmentKey)
        }
    }

    /// 便捷切换环境（仅 Debug 可用）
    static func switchTo(_ environment: ServerEnvironment) {
        current = environment
    }
    #else
    /// 生产发布包强制锁定线上环境，不可被篡改
    static let current: ServerEnvironment = .prod
    #endif

    /// REST API 根地址（自动追加版本前缀，随当前环境动态返回）
    static var apiBaseURL: URL {
        current.baseURL.appending(path: "api/v1")
    }

    /// WebSocket 实时通信地址（协议自动根据 http/https 切换为 ws/wss）
    static var chatWebSocketURL: URL {
        var components = URLComponents(url: current.baseURL, resolvingAgainstBaseURL: false)!
        components.scheme = components.scheme == "https" ? "wss" : "ws"
        components.path = "/ws/chat"
        return components.url!
    }
}
