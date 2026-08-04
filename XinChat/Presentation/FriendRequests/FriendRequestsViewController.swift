import SnapKit
import UIKit

/// 好友申请收件箱，只有当前登录用户可以处理发给自己的申请。
final class FriendRequestsViewController: UIViewController {
    private let viewModel: FriendRequestsViewModel
    private let appBar = AppBarView(title: "新的朋友")
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let loadingView = UIActivityIndicatorView(style: .large)
    private let emptyLabel = UILabel()

    init(viewModel: FriendRequestsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        viewModel.load()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func setupUI() {
        view.backgroundColor = AppTheme.background
        appBar.onBackTapped = { [weak self] in self?.navigationController?.popViewController(animated: true) }
        tableView.rowHeight = 82
        tableView.dataSource = self
        tableView.register(FriendRequestCell.self, forCellReuseIdentifier: FriendRequestCell.reuseIdentifier)
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        emptyLabel.text = "暂无新的好友申请"
        emptyLabel.textColor = AppTheme.secondaryText
        emptyLabel.textAlignment = .center

        [appBar, tableView, loadingView, emptyLabel].forEach(view.addSubview)
        appBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(AppBarView.contentHeight)
        }
        tableView.snp.makeConstraints {
            $0.top.equalTo(appBar.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        loadingView.snp.makeConstraints { $0.center.equalTo(tableView) }
        emptyLabel.snp.makeConstraints { $0.center.equalTo(tableView) }
    }

    private func bind() {
        viewModel.onStateChanged = { [weak self] state in
            guard let self else { return }
            tableView.refreshControl?.endRefreshing()
            switch state {
            case .loading: loadingView.startAnimating()
            case .idle, .loaded: loadingView.stopAnimating()
            case let .failed(message):
                loadingView.stopAnimating()
                showError(message)
            }
        }
        viewModel.onDataChanged = { [weak self] in
            guard let self else { return }
            tableView.reloadData()
            emptyLabel.isHidden = !viewModel.requests.isEmpty
        }
        viewModel.onError = { [weak self] message in self?.showError(message) }
    }

    @objc private func refresh() { viewModel.load() }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "操作失败", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "知道了", style: .default))
        present(alert, animated: true)
    }
}

extension FriendRequestsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.requests.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: FriendRequestCell.reuseIdentifier,
            for: indexPath
        ) as? FriendRequestCell else { return UITableViewCell() }
        let request = viewModel.requests[indexPath.row]
        cell.configure(
            request: request,
            processing: viewModel.processingIDs.contains(request.id),
            onAccept: { [weak self] in self?.viewModel.accept(request) },
            onReject: { [weak self] in self?.viewModel.reject(request) }
        )
        return cell
    }
}
