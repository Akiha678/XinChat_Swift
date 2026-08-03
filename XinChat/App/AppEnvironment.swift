import Foundation

/// 应用环境地址集中配置，确保 REST 与 WebSocket 始终指向同一后端。
enum AppEnvironment {
    // 真机调试使用开发机局域网地址；仅模拟器可改为 127.0.0.1。
    static let serverBaseURL = URL(string: "http://192.168.1.14:8080")!
    static let apiBaseURL = serverBaseURL.appending(path: "api/v1")

    static var chatWebSocketURL: URL {
        var components = URLComponents(url: serverBaseURL, resolvingAgainstBaseURL: false)!
        components.scheme = components.scheme == "https" ? "wss" : "ws"
        components.path = "/ws/chat"
        components.query = nil
        return components.url!
    }
}
