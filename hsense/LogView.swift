import UIKit

class LogView: UIView {
    // MARK: - Properties
    private let textView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.isSelectable = true
        textView.font = .systemFont(ofSize: 14)
        textView.backgroundColor = .black.withAlphaComponent(0.8)
        textView.textColor = .white
        textView.layer.cornerRadius = 8
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Share", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 6
        button.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        button.tintColor = .white
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 0)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let copyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Copy", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 6
        button.setImage(UIImage(systemName: "doc.on.doc"), for: .normal)
        button.tintColor = .white
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 0)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let clearButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Clear", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 6
        button.setImage(UIImage(systemName: "trash"), for: .normal)
        button.tintColor = .white
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 0)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let minimizeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("−", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12)
        button.backgroundColor = .systemGray
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 6
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var isMinimized = false
    private var logEntries: [LogEntry] = []
    private let maxLogEntries = 100
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        backgroundColor = .clear
        
        addSubview(textView)
        addSubview(buttonStackView)
        
        buttonStackView.addArrangedSubview(shareButton)
        buttonStackView.addArrangedSubview(copyButton)
        buttonStackView.addArrangedSubview(clearButton)
        buttonStackView.addArrangedSubview(minimizeButton)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: topAnchor),
            textView.leadingAnchor.constraint(equalTo: leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: buttonStackView.topAnchor, constant: -8),
            
            buttonStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            buttonStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            buttonStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            buttonStackView.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        copyButton.addTarget(self, action: #selector(copyButtonTapped), for: .touchUpInside)
        clearButton.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
        minimizeButton.addTarget(self, action: #selector(minimizeButtonTapped), for: .touchUpInside)
        
        // Add pan gesture for dragging
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        addGestureRecognizer(panGesture)
    }
    
    // MARK: - Actions
    @objc private func shareButtonTapped() {
        let logText = textView.text ?? ""
        let activityVC = UIActivityViewController(activityItems: [logText], applicationActivities: nil)
        
        // For iPad
        if let popoverController = activityVC.popoverPresentationController {
            popoverController.sourceView = shareButton
            popoverController.sourceRect = shareButton.bounds
        }
        
        // Get the top view controller to present the share sheet
        if let topVC = UIApplication.shared.windows.first?.rootViewController {
            topVC.present(activityVC, animated: true)
        }
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
    
    @objc private func clearButtonTapped() {
        logEntries.removeAll()
        updateTextView()
    }
    
    @objc private func minimizeButtonTapped() {
        isMinimized.toggle()
        UIView.animate(withDuration: 0.3) {
            self.textView.alpha = self.isMinimized ? 0 : 1
            self.buttonStackView.alpha = self.isMinimized ? 0 : 1
            self.minimizeButton.setTitle(self.isMinimized ? "+" : "−", for: .normal)
        }
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let superview = superview else { return }
        let translation = gesture.translation(in: superview)
        
        switch gesture.state {
        case .changed:
            center = CGPoint(x: center.x + translation.x, y: center.y + translation.y)
            gesture.setTranslation(.zero, in: superview)
        default:
            break
        }
    }
    
    // MARK: - Public Methods
    func log(_ message: String, type: LogType = .info) {
        let entry = LogEntry(message: message, type: type, timestamp: Date())
        logEntries.append(entry)
        
        if logEntries.count > maxLogEntries {
            logEntries.removeFirst()
        }
        
        updateTextView()
    }
    
    func getLogEntries() -> [LogEntry] {
        return logEntries
    }
    
    // MARK: - Private Methods
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
}

// MARK: - Supporting Types
struct LogEntry {
    let message: String
    let type: LogType
    let timestamp: Date
}

enum LogType {
    case info
    case success
    case warning
    case error
    
    var color: UIColor {
        switch self {
        case .info: return .white
        case .success: return .systemGreen
        case .warning: return .systemYellow
        case .error: return .systemRed
        }
    }
}

// MARK: - DateFormatter Extension
extension DateFormatter {
    static let logFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
} 