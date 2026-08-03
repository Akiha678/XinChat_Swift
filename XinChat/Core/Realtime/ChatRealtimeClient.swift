import Foundation
import UIKit

enum ChatRealtimeEvent {
    case connected
    case disconnected
    case messageCreated(ChatMessage)
}

protocol ChatRealtimeClientProtocol: AnyObject {
    func connect(accessToken: String)
    func disconnect()
    @discardableResult
    func observe(_ handler: @escaping (ChatRealtimeEvent) -> Void) -> UUID
    func removeObserver(_ token: UUID)
}

///
/// 应用级 WebSocket 客户端：
/// - 使用 Keychain 中的 Bearer Token 完成握手；
/// - 断线后指数退避重连；
/// - 心跳发现半开连接；
/// - 将稳定的服务端事件广播给业务 ViewModel。
///
final class ChatRealtimeClient: NSObject, ChatRealtimeClientProtocol {
    private struct Envelope: Decodable {
        let type: String
        let data: ChatMessage
    }

    private var observers: [UUID: (ChatRealtimeEvent) -> Void] = [:]
    private var webSocketTask: URLSessionWebSocketTask?
    private var receiveTask: Task<Void, Never>?
    private var reconnectTask: Task<Void, Never>?
    private var heartbeatTimer: Timer?
    private var accessToken: String?
    private var reconnectAttempt = 0
    private var shouldReconnect = false
    private var isConnected = false

    private lazy var session = URLSession(
        configuration: .default,
        delegate: self,
        delegateQueue: nil
    )

    override init() {
        super.init()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func connect(accessToken: String) {
        self.accessToken = accessToken
        shouldReconnect = true
        guard webSocketTask == nil else { return }
        establishConnection()
    }

    func disconnect() {
        shouldReconnect = false
        accessToken = nil
        reconnectTask?.cancel()
        reconnectTask = nil
        stopHeartbeat()
        receiveTask?.cancel()
        receiveTask = nil
        let task = webSocketTask
        webSocketTask = nil
        task?.cancel(with: .goingAway, reason: nil)
        updateConnected(false)
    }

    @discardableResult
    func observe(_ handler: @escaping (ChatRealtimeEvent) -> Void) -> UUID {
        let token = UUID()
        observers[token] = handler
        return token
    }

    func removeObserver(_ token: UUID) {
        observers.removeValue(forKey: token)
    }

    private func establishConnection() {
        guard shouldReconnect, let accessToken, webSocketTask == nil else { return }
        var request = URLRequest(url: AppEnvironment.chatWebSocketURL)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 15
        let task = session.webSocketTask(with: request)
        webSocketTask = task
        task.resume()
    }

    private func startReceiving(from task: URLSessionWebSocketTask) {
        receiveTask?.cancel()
        receiveTask = Task { [weak self, weak task] in
            guard let self, let task else { return }
            do {
                while !Task.isCancelled {
                    let message = try await task.receive()
                    handle(message)
                }
            } catch {
                handleConnectionLost(task)
            }
        }
    }

    private func handle(_ message: URLSessionWebSocketTask.Message) {
        let data: Data?
        switch message {
        case let .string(text): data = text.data(using: .utf8)
        case let .data(binary): data = binary
        @unknown default: data = nil
        }
        guard let data,
              let envelope = try? JSONDecoder().decode(Envelope.self, from: data),
              envelope.type == "message.created" else { return }
        notify(.messageCreated(envelope.data))
    }

    private func handleOpened(_ task: URLSessionWebSocketTask) {
        guard task === webSocketTask else { return }
        reconnectAttempt = 0
        updateConnected(true)
        startReceiving(from: task)
        startHeartbeat()
    }

    private func handleConnectionLost(_ task: URLSessionWebSocketTask) {
        guard task === webSocketTask else { return }
        webSocketTask = nil
        receiveTask?.cancel()
        receiveTask = nil
        stopHeartbeat()
        updateConnected(false)
        scheduleReconnect()
    }

    private func scheduleReconnect() {
        guard shouldReconnect, reconnectTask == nil else { return }
        let delay = min(pow(2.0, Double(reconnectAttempt)), 30)
        reconnectAttempt += 1
        reconnectTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(delay))
            guard !Task.isCancelled, let self else { return }
            reconnectTask = nil
            establishConnection()
        }
    }

    private func startHeartbeat() {
        stopHeartbeat()
        heartbeatTimer = Timer.scheduledTimer(withTimeInterval: 20, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in self?.sendPing() }
        }
    }

    private func stopHeartbeat() {
        heartbeatTimer?.invalidate()
        heartbeatTimer = nil
    }

    private func sendPing() {
        guard let task = webSocketTask else { return }
        task.sendPing { [weak self, weak task] error in
            guard error != nil, let task else { return }
            Task { @MainActor [weak self] in self?.handleConnectionLost(task) }
        }
    }

    private func updateConnected(_ connected: Bool) {
        guard isConnected != connected else { return }
        isConnected = connected
        notify(connected ? .connected : .disconnected)
    }

    private func notify(_ event: ChatRealtimeEvent) {
        observers.values.forEach { $0(event) }
    }

    @objc private func applicationDidBecomeActive() {
        if shouldReconnect, webSocketTask == nil {
            reconnectTask?.cancel()
            reconnectTask = nil
            establishConnection()
        }
    }
}

extension ChatRealtimeClient: URLSessionWebSocketDelegate {
    nonisolated func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didOpenWithProtocol protocol: String?
    ) {
        Task { @MainActor [weak self] in self?.handleOpened(webSocketTask) }
    }

    nonisolated func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
        reason: Data?
    ) {
        Task { @MainActor [weak self] in self?.handleConnectionLost(webSocketTask) }
    }
}
