import Foundation

/// 收到的好友申请列表及接受/拒绝业务状态。
final class FriendRequestsViewModel {
    enum State {
        case idle
        case loading
        case loaded
        case failed(String)
    }

    private let repository: ChatRepositoryProtocol
    private(set) var requests: [FriendRequest] = []
    private(set) var processingIDs: Set<Int> = []

    var onStateChanged: ((State) -> Void)?
    var onDataChanged: (() -> Void)?
    var onError: ((String) -> Void)?

    init(repository: ChatRepositoryProtocol) {
        self.repository = repository
    }

    func load() {
        onStateChanged?(.loading)
        repository.fetchIncomingFriendRequests { [weak self] result in
            guard let self else { return }
            switch result {
            case let .success(requests):
                self.requests = requests
                onStateChanged?(.loaded)
                onDataChanged?()
            case let .failure(error):
                onStateChanged?(.failed(error.localizedDescription))
            }
        }
    }

    func accept(_ request: FriendRequest) {
        handle(request, accept: true)
    }

    func reject(_ request: FriendRequest) {
        handle(request, accept: false)
    }

    private func handle(_ request: FriendRequest, accept: Bool) {
        guard !processingIDs.contains(request.id) else { return }
        processingIDs.insert(request.id)
        onDataChanged?()

        let completion: (Result<FriendRequest, NetworkError>) -> Void = { [weak self] result in
            guard let self else { return }
            processingIDs.remove(request.id)
            switch result {
            case .success:
                requests.removeAll { $0.id == request.id }
                onDataChanged?()
            case let .failure(error):
                onDataChanged?()
                onError?(error.localizedDescription)
            }
        }
        if accept {
            repository.acceptFriendRequest(requestID: request.id, completion: completion)
        } else {
            repository.rejectFriendRequest(requestID: request.id, completion: completion)
        }
    }
}
