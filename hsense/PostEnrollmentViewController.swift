import UIKit
import IntuneMAMSwift
import MSAL

class PostEnrollmentViewController: UIViewController {
    
    private let statusImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark.circle.fill")
        imageView.tintColor = .systemGreen
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Sign in Successful"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let enrollmentStatusLabel: UILabel = {
        let label = UILabel()
        label.text = "Enrolling device..."
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .gray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private let diagnosticButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Show Diagnostic Console", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.backgroundColor = .systemOrange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = Constants.UI.cornerRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let viewLogsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("View Logs", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = Constants.UI.cornerRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Back to Login", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = Constants.UI.cornerRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var enrollmentCheckTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Logger.shared.info("📱 PostEnrollmentViewController loaded")
        Logger.shared.info("📱 Setting up enrollment view")
        setupUI()
        setupNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Logger.shared.info("📱 PostEnrollmentViewController will appear")
        startEnrollmentCheck()
        
        // Ensure logger is visible
        if let window = view.window {
            Logger.shared.setWindow(window)
            Logger.shared.setup()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Logger.shared.info("📱 PostEnrollmentViewController did appear")
        checkInitialEnrollmentStatus()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Logger.shared.info("📱 PostEnrollmentViewController will disappear")
        stopEnrollmentCheck()
    }
    
    private func setupNotifications() {
        Logger.shared.info("📱 Setting up enrollment notifications")
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleEnrollmentSucceeded),
            name: Notification.Name("IntuneEnrollmentSucceeded"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleEnrollmentFailed),
            name: Notification.Name("IntuneEnrollmentFailed"),
            object: nil
        )
        
        Logger.shared.success("✅ Enrollment notifications setup completed")
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "Device Enrollment"
        
        Logger.shared.info("📱 Setting up UI components")
        
        view.addSubview(statusImageView)
        view.addSubview(statusLabel)
        view.addSubview(enrollmentStatusLabel)
        view.addSubview(activityIndicator)
        view.addSubview(diagnosticButton)
        view.addSubview(viewLogsButton)
        view.addSubview(backButton)
        
        NSLayoutConstraint.activate([
            statusImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            statusImageView.widthAnchor.constraint(equalToConstant: 80),
            statusImageView.heightAnchor.constraint(equalToConstant: 80),
            
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.topAnchor.constraint(equalTo: statusImageView.bottomAnchor, constant: 20),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            enrollmentStatusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            enrollmentStatusLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 16),
            enrollmentStatusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            enrollmentStatusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: enrollmentStatusLabel.bottomAnchor, constant: 20),
            
            diagnosticButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            diagnosticButton.bottomAnchor.constraint(equalTo: viewLogsButton.topAnchor, constant: -20),
            diagnosticButton.widthAnchor.constraint(equalToConstant: Constants.UI.buttonWidth),
            diagnosticButton.heightAnchor.constraint(equalToConstant: Constants.UI.buttonHeight),
            
            viewLogsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            viewLogsButton.bottomAnchor.constraint(equalTo: backButton.topAnchor, constant: -20),
            viewLogsButton.widthAnchor.constraint(equalToConstant: Constants.UI.buttonWidth),
            viewLogsButton.heightAnchor.constraint(equalToConstant: Constants.UI.buttonHeight),
            
            backButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            backButton.widthAnchor.constraint(equalToConstant: Constants.UI.buttonWidth),
            backButton.heightAnchor.constraint(equalToConstant: Constants.UI.buttonHeight)
        ])
        
        diagnosticButton.addTarget(self, action: #selector(diagnosticButtonTapped), for: .touchUpInside)
        viewLogsButton.addTarget(self, action: #selector(viewLogsButtonTapped), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        activityIndicator.startAnimating()
        Logger.shared.success("✅ UI setup completed")
    }
    
    private func checkInitialEnrollmentStatus() {
        Logger.shared.info("📱 Checking initial enrollment status")
        let policyManager = IntuneMAMPolicyManager.instance()
        if policyManager.isManagementEnabled() {
            Logger.shared.success("✅ Device is already enrolled with Intune")
            updateEnrollmentStatus(success: true)
        } else {
            Logger.shared.info("📱 Device not yet enrolled, waiting for enrollment process...")
        }
    }
    
    private func startEnrollmentCheck() {
        Logger.shared.info("📱 Starting enrollment status check")
        stopEnrollmentCheck() // Stop any existing timer
        
        enrollmentCheckTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            DispatchQueue.main.async {
                let policyManager = IntuneMAMPolicyManager.instance()
                if policyManager.isManagementEnabled() {
                    Logger.shared.success("✅ Device is now enrolled with Intune")
                    self.updateEnrollmentStatus(success: true)
                    self.stopEnrollmentCheck()
                }
            }
        }
    }
    
    private func stopEnrollmentCheck() {
        Logger.shared.info("📱 Stopping enrollment status check")
        enrollmentCheckTimer?.invalidate()
        enrollmentCheckTimer = nil
    }
    
    @objc private func handleEnrollmentSucceeded() {
        Logger.shared.success("✅ Enrollment succeeded notification received")
        Logger.shared.info("📱 Device is now managed by Intune")
        updateEnrollmentStatus(success: true)
    }
    
    @objc private func handleEnrollmentFailed(_ notification: Notification) {
        if let error = notification.userInfo?["error"] as? Error {
            Logger.shared.error("❌ Enrollment failed: \(error.localizedDescription)")
            Logger.shared.error("❌ Error details: \(error)")
            updateEnrollmentStatus(success: false)
        }
    }
    
    private func updateEnrollmentStatus(success: Bool) {
        Logger.shared.info("📱 Updating enrollment status UI: \(success ? "Success" : "Failed")")
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.activityIndicator.stopAnimating()
            
            if success {
                self.statusImageView.image = UIImage(systemName: "checkmark.circle.fill")
                self.statusImageView.tintColor = .systemGreen
                self.statusLabel.text = "Device Enrolled"
                self.enrollmentStatusLabel.text = "Your device has been successfully enrolled in Intune."
                Logger.shared.success("✅ Enrollment UI updated to success state")
                
                // Add a slight delay before proceeding
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    Logger.shared.info("📱 Dismissing PostEnrollmentViewController")
                    self.dismiss(animated: true)
                }
            } else {
                self.statusImageView.image = UIImage(systemName: "xmark.circle.fill")
                self.statusImageView.tintColor = .systemRed
                self.statusLabel.text = "Enrollment Failed"
                self.enrollmentStatusLabel.text = "There was an error enrolling your device. Please try again."
                Logger.shared.error("❌ Enrollment UI updated to failure state")
            }
        }
    }
    
    @objc private func diagnosticButtonTapped() {
        Logger.shared.info("📱 Opening Intune diagnostic console")
        IntuneMAMDiagnosticConsole.display()
    }
    
    @objc private func viewLogsButtonTapped() {
        Logger.shared.info("📱 View Logs button tapped")
        let logViewerVC = LogViewerViewController()
        logViewerVC.modalPresentationStyle = .overFullScreen
        present(logViewerVC, animated: true)
    }
    
    @objc private func backButtonTapped() {
        Logger.shared.info("📱 Back button tapped")
        Logger.shared.info("📱 Returning to login screen")
        dismiss(animated: true)
    }
    
    deinit {
        Logger.shared.info("📱 PostEnrollmentViewController deinitialized")
        stopEnrollmentCheck()
        NotificationCenter.default.removeObserver(self)
    }
} 
