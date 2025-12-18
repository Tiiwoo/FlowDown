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
    let session: EvaluationSession
    let statusView: EvaluationStatusCollectionView

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
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "square.and.arrow.up"),
            style: .plain,
            target: self,
            action: #selector(shareTapped),
        )
        navigationItem.rightBarButtonItem?.accessibilityLabel = String(localized: "Share")
    }

    @objc private func shareTapped() {
        _ = try? EvaluationSessionManager.shared.save(session)

        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        guard let data = try? encoder.encode(session) else { return }

        let exporter = DisposableExporter(
            data: data,
            name: "evaluation-session-\(session.id.uuidString)",
            pathExtension: "plist",
        )
        exporter.run(anchor: view, mode: .file)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        guard isMovingFromParent || isBeingDismissed else { return }
        session.stopAndDispose(save: true)
    }

    private func updateTitle() {
        title = session.isCompleted ? String(localized: "Evaluation Result") : String(localized: "Running Evaluation")
    }

    @objc func sessionDidUpdate() {
        if Thread.isMainThread {
            statusView.applySessionUpdate(animated: true)
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
