//
//  EvaluationStatusController.swift
//  FlowDown
//
//  Created by qaq on 18/12/2025.
//

import AlertController
import GlyphixTextFx
import SnapKit
import UIKit

final class EvaluationStatusController: UIViewController {
    private static let exportDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    let session: EvaluationSession
    let statusView: EvaluationStatusCollectionView

    private var outcomeFilter: EvaluationManifest.Suite.Case.Result.Outcome?

    private enum OutcomeFilterOption: CaseIterable {
        case all
        case passed
        case failed
        case running
        case judging
        case pending

        var titleKey: String.LocalizationValue {
            switch self {
            case .all:
                "All"
            case .passed:
                "Passed"
            case .failed:
                "Failed"
            case .running:
                "Running"
            case .judging:
                "Judging"
            case .pending:
                "Pending"
            }
        }

        var outcome: EvaluationManifest.Suite.Case.Result.Outcome? {
            switch self {
            case .all:
                nil
            case .passed:
                .pass
            case .failed:
                .fail
            case .running:
                .processing
            case .judging:
                .awaitingJudging
            case .pending:
                .notDetermined
            }
        }
    }

    private lazy var shareBarItem: UIBarButtonItem = {
        let item = UIBarButtonItem(
            image: UIImage(systemName: "square.and.arrow.up"),
            style: .plain,
            target: self,
            action: #selector(shareTapped),
        )
        item.accessibilityLabel = String(localized: "Share")
        return item
    }()

    private lazy var filterBarItem: UIBarButtonItem = {
        let deferredMenu = UIDeferredMenuElement.uncached { [weak self] completion in
            guard let self else {
                completion([])
                return
            }
            completion(createFilterMenuItems())
        }
        let item = UIBarButtonItem(
            image: .init(systemName: "line.3.horizontal.decrease.circle"),
            menu: UIMenu(title: String(localized: "Filter Options"), children: [deferredMenu]),
        )
        item.accessibilityLabel = String(localized: "Filter Options")
        return item
    }()

    init(session: EvaluationSession) {
        self.session = session
        statusView = EvaluationStatusCollectionView(session: session)
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateTitle()
        view.backgroundColor = .systemBackground

        setupNavigation()
        setupStatusView()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(sessionDidUpdate),
            name: .evaluationSessionDidUpdate,
            object: session,
        )

        session.resume()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func setupNavigation() {
        navigationItem.rightBarButtonItems = [
            shareBarItem,
            filterBarItem,
        ]
        updateFilterIcon()
    }

    private func createFilterMenuItems() -> [UIMenuElement] {
        OutcomeFilterOption.allCases.map { option in
            UIAction(
                title: String(localized: option.titleKey),
                state: outcomeFilter == option.outcome ? .on : .off,
            ) { [weak self] _ in
                self?.applyOutcomeFilter(option.outcome)
            }
        }
    }

    private func applyOutcomeFilter(_ filter: EvaluationManifest.Suite.Case.Result.Outcome?) {
        outcomeFilter = filter
        statusView.setOutcomeFilter(filter)
        updateFilterIcon()
    }

    private func updateFilterIcon() {
        if outcomeFilter == nil {
            filterBarItem.image = .init(systemName: "line.3.horizontal.decrease.circle")
        } else {
            filterBarItem.image = .init(systemName: "line.3.horizontal.decrease.circle.fill")
        }
    }

    @objc private func shareTapped() {
        _ = try? EvaluationSessionManager.shared.save(session)

        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        guard let data = try? encoder.encode(session) else { return }

        let modelName = ModelManager.shared
            .modelName(identifier: session.modelIdentifier)
            .sanitizedFileName
        let dateTime = Self.exportDateFormatter.string(from: Date())
        let exportName = "ModelEvaluationResult-\(modelName)-\(dateTime)"

        let exporter = DisposableExporter(
            data: data,
            name: exportName,
            pathExtension: "fdem",
        )
        exporter.run(anchor: view, mode: .file)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        guard isMovingFromParent || isBeingDismissed else { return }
        session.stopAndDispose(save: true)
    }

    private func updateTitle() {
        if !session.isCompleted {
            title = String(localized: "Running Evaluation")
            return
        }

        var total = 0
        var passed = 0
        for manifest in session.manifests {
            for suite in manifest.suites {
                for caseItem in suite.cases {
                    total += 1
                    if caseItem.results.last?.outcome == .pass {
                        passed += 1
                    }
                }
            }
        }

        let passedText = String(localized: "Passed")
        let allText = String(localized: "All")
        title = "\(passed)/\(total) \(passedText)/\(allText)"
    }

    @objc func sessionDidUpdate() {
        if Thread.isMainThread {
            statusView.applySessionUpdate(animated: false)
            updateTitle()
        } else {
            DispatchQueue.main.async {
                self.sessionDidUpdate()
            }
        }
    }

    func setupStatusView() {
        view.addSubview(statusView)
        statusView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.right.bottom.equalToSuperview()
        }

        statusView.onSelectCase = { [weak self] caseItem in
            guard let self else { return }
            let detailVC = EvaluationCaseDetailController(caseItem: caseItem, session: session)
            navigationController?.pushViewController(detailVC, animated: true)
        }

        statusView.applySessionUpdate(animated: false)
    }
}
