//
//  EvaluationHistoryController.swift
//  FlowDown
//
//  Created by qaq on 18/12/2025.
//

import AlertController
import ConfigurableKit
import Logger
import SnapKit
import UIKit

class EvaluationHistoryController: UIViewController {
    private enum Section: Hashable {
        case main
    }

    private var sessions: [EvaluationSession] = []

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .clear
        tv.separatorStyle = .singleLine
        tv.separatorInset = .zero
        tv.delegate = self
        tv.register(HistoryCell.self, forCellReuseIdentifier: HistoryCell.reuseIdentifier)
        return tv
    }()

    private lazy var dataSource: UITableViewDiffableDataSource<Section, UUID> = .init(tableView: tableView) { [weak self] tableView, indexPath, itemIdentifier in
        guard let self else { return UITableViewCell() }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HistoryCell.reuseIdentifier, for: indexPath) as? HistoryCell else {
            return UITableViewCell()
        }
        guard let session = session(for: itemIdentifier) else {
            cell.prepareForReuse()
            return cell
        }
        cell.load(session: session, modelTitle: modelTitle(for: session.modelIdentifier))
        return cell
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = String(localized: "Evaluation History")
        view.backgroundColor = .systemBackground

        navigationItem.rightBarButtonItem = deleteAllBarButtonItem

        setupView()
        loadData(animated: false)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData(animated: false)
    }

    private lazy var deleteAllBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(
            image: UIImage(systemName: "trash"),
            style: .plain,
            target: self,
            action: #selector(deleteAllTapped),
        )
        item.tintColor = .systemRed
        return item
    }()

    @objc private func deleteAllTapped() {
        let alert = AlertViewController(
            title: "Delete All Evaluation Sessions",
            message: "Are you sure you want to delete all evaluation sessions?",
        ) { [weak self] context in
            context.addAction(title: "Cancel") {
                context.dispose()
            }
            context.addAction(title: "Erase All", attribute: .accent) {
                context.dispose {
                    guard let self else { return }
                    do {
                        try EvaluationSessionManager.shared.deleteAll()
                        self.sessions.removeAll()
                        self.applySnapshot(animated: true)
                        Indicator.present(
                            title: "Deleted",
                            referencingView: self.view,
                        )
                    } catch {
                        Logger.app.errorFile("failed to delete all evaluation sessions: \(error)")
                        let errorAlert = AlertViewController(
                            title: String(localized: "Error"),
                            message: error.localizedDescription,
                        ) { context in
                            context.allowSimpleDispose()
                            context.addAction(title: "OK", attribute: .accent) {
                                context.dispose()
                            }
                        }
                        self.present(errorAlert, animated: true)
                    }
                }
            }
        }
        present(alert, animated: true)
    }

    private func setupView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func loadData(animated: Bool) {
        do {
            sessions = try EvaluationSessionManager.shared.listSessions()
            applySnapshot(animated: animated, reloadItems: true)
        } catch {
            Logger.app.errorFile("failed to load sessions: \(error)")
        }
    }

    private func applySnapshot(animated: Bool, reloadItems: Bool = false) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, UUID>()
        snapshot.appendSections([.main])
        let ids = sessions.map(\.id)
        snapshot.appendItems(ids, toSection: .main)
        if reloadItems {
            snapshot.reloadItems(ids)
        }
        dataSource.apply(snapshot, animatingDifferences: animated)
    }

    private func session(for id: UUID) -> EvaluationSession? {
        sessions.first(where: { $0.id == id })
    }

    private func modelTitle(for identifier: ModelManager.ModelIdentifier) -> String {
        if let localModel = ModelManager.shared.localModel(identifier: identifier) {
            return localModel.model_identifier
        }
        if let cloudModel = ModelManager.shared.cloudModel(identifier: identifier) {
            return cloudModel.modelFullName
        }
        return identifier
    }
}

extension EvaluationHistoryController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let id = dataSource.itemIdentifier(for: indexPath) else { return nil }
        let delete = UIContextualAction(
            style: .destructive,
            title: String(localized: "Delete"),
        ) { [weak self] _, _, completion in
            guard let self else { completion(false); return }
            do {
                try EvaluationSessionManager.shared.delete(id: id)
                sessions.removeAll(where: { $0.id == id })
                applySnapshot(animated: true)
                completion(true)
            } catch {
                completion(false)
            }
        }
        delete.image = UIImage(systemName: "trash")
        return UISwipeActionsConfiguration(actions: [delete])
    }
}

private extension EvaluationHistoryController {
    final class HistoryCell: UITableViewCell {
        static let reuseIdentifier = "EvaluationHistoryCell"

        private var session: EvaluationSession?

        private lazy var pageView = ConfigurablePageView { [weak self] in
            guard let session = self?.session else { return nil }
            return EvaluationStatusController(session: session)
        }

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            selectionStyle = .none
            backgroundColor = .clear
            clipsToBounds = true

            let wrappingView = AutoLayoutMarginView(pageView)
            contentView.addSubview(wrappingView)
            wrappingView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }

            pageView.isUserInteractionEnabled = true
            pageView.descriptionLabel.numberOfLines = 1
            pageView.descriptionLabel.lineBreakMode = .byTruncatingTail
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func prepareForReuse() {
            super.prepareForReuse()
            session = nil
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            preservesSuperviewLayoutMargins = false
            separatorInset = .zero
            layoutMargins = .zero
        }

        func load(session: EvaluationSession, modelTitle: String) {
            self.session = session
            pageView.configure(icon: .init(systemName: "chart.bar.xaxis"))
            pageView.configure(title: modelTitle)
            pageView.configure(description: session.createdAt.formatted(date: .abbreviated, time: .shortened))
        }
    }
}
