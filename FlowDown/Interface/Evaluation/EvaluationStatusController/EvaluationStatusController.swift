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
        title = String(localized: "Evaluating")
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

    func setupNavigation() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis.circle"),
            menu: makeMenu(),
        )
        navigationItem.rightBarButtonItem?.accessibilityLabel = "More"

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "stop.circle"),
            style: .plain,
            target: self,
            action: #selector(stopTapped),
        )
        navigationItem.leftBarButtonItem?.tintColor = .systemRed
    }

    @MainActor
    func menuElements() -> [UIMenuElement] {
        // Intentionally left blank.
        // Leave the menu implementation to the caller/owner.
        []
    }

    private func makeMenu() -> UIMenu {
        UIMenu(children: menuElements())
    }

    @objc func stopTapped() {
        session.stop()
        statusView.setStopped()
        let alert = AlertViewController(
            title: String(localized: "Session Stopped"),
            message: String(localized: "Progress has been saved. You can resume this session later."),
        ) { context in
            context.addAction(title: "OK", attribute: .accent) {
                context.dispose { [weak self] in
                    self?.dismiss(animated: true)
                }
            }
        }
        present(alert, animated: true)
    }

    @objc func sessionDidUpdate() {
        if Thread.isMainThread {
            statusView.applySessionUpdate(animated: true)
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
