import Foundation

final class ContactsViewModel {
    enum State {
        case idle
        case loading
        case loaded([Contact])
        case failed(String)
    }

    private let repository: ChatRepositoryProtocol
    private(set) var state: State = .idle {
        didSet { onStateChanged?(state) }
    }

    var onStateChanged: ((State) -> Void)?

    init(repository: ChatRepositoryProtocol) {
        self.repository = repository
    }

    func load() {
        state = .loading
        repository.fetchContacts { [weak self] result in
            switch result {
            case let .success(contacts): self?.state = .loaded(contacts)
            case let .failure(error): self?.state = .failed(error.localizedDescription)
            }
        }
    }
}
