import UIKit

class LogViewerViewController: UIViewController {
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.9)
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Log Viewer"
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.textColor = .white
        textView.font = .systemFont(ofSize: 14)
        textView.isEditable = false
        textView.isSelectable = true
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Share", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        button.tintColor = .white
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let copyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Copy", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.setImage(UIImage(systemName: "doc.on.doc"), for: .normal)
        button.tintColor = .white
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Close", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .white
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var logEntries: [LogEntry] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadLogs()
    }
    
    private func setupUI() {
        view.backgroundColor = .clear
        
        view.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(textView)
        containerView.addSubview(buttonStackView)
        
        buttonStackView.addArrangedSubview(shareButton)
        buttonStackView.addArrangedSubview(copyButton)
        buttonStackView.addArrangedSubview(closeButton)
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            containerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.7),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            textView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            textView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            textView.bottomAnchor.constraint(equalTo: buttonStackView.topAnchor, constant: -16),
            
            buttonStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            buttonStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            buttonStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            buttonStackView.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        copyButton.addTarget(self, action: #selector(copyButtonTapped), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }
    
    private func loadLogs() {
        // Get logs from Logger singleton
        if let logView = Logger.shared.getLogView() {
            logEntries = logView.getLogEntries()
            updateTextView()
        }
    }
    
    private func updateTextView() {
        let attributedText = NSMutableAttributedString()
        
        for entry in logEntries {
            let timestamp = DateFormatter.logFormatter.string(from: entry.timestamp)
            let prefix = "[\(timestamp)] "
            
            let entryString = prefix + entry.message + "\n"
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: entry.type.color
            ]
            
            attributedText.append(NSAttributedString(string: entryString, attributes: attributes))
        }
        
        textView.attributedText = attributedText
        
        // Scroll to bottom
        let range = NSRange(location: textView.text.count - 1, length: 1)
        textView.scrollRangeToVisible(range)
    }
    
    @objc private func shareButtonTapped() {
        let logText = textView.text ?? ""
        let activityVC = UIActivityViewController(activityItems: [logText], applicationActivities: nil)
        
        // For iPad
        if let popoverController = activityVC.popoverPresentationController {
            popoverController.sourceView = shareButton
            popoverController.sourceRect = shareButton.bounds
        }
        
        present(activityVC, animated: true)
    }
    
    @objc private func copyButtonTapped() {
        let logText = textView.text ?? ""
        UIPasteboard.general.string = logText
        
        // Show feedback
        let feedbackGenerator = UINotificationFeedbackGenerator()
        feedbackGenerator.notificationOccurred(.success)
        
        // Show temporary "Copied" message
        let originalTitle = copyButton.title(for: .normal)
        copyButton.setTitle("Copied!", for: .normal)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.copyButton.setTitle(originalTitle, for: .normal)
        }
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
} 