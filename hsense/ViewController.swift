//
//  ViewController.swift
//  Created by Vivek Ellappan on 08/05/25.
//

import UIKit
import MSAL
import IntuneMAMSwift


class ViewController: UIViewController {

    private var applicationContext: MSALPublicClientApplication?
    private var webViewParameters: MSALWebviewParameters?
    
    // MARK: - UI Components
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.tintColor = .systemBlue
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome to HSense"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Sign in with your Microsoft Account"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .gray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign in with Microsoft", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = UIColor.systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = Constants.UI.cornerRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let diagnosticButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Show Diagnostic Console", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.backgroundColor = .systemOrange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = Constants.UI.cornerRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let resultLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        Logger.shared.info("ViewController loaded")
        Logger.shared.success("Test success message")
        Logger.shared.warning("Test warning message")
        Logger.shared.error("Test error message")
        setupUI()
        initMSAL()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Logger.shared.info("ViewController will appear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Logger.shared.info("ViewController did appear")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white
        
        // Add scrollView and contentView
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Add UI components to contentView instead of main view
        contentView.addSubview(logoImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(loginButton)
        contentView.addSubview(diagnosticButton)
        contentView.addSubview(resultLabel)
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            // ScrollView constraints
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // ContentView constraints
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Logo constraints
            logoImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            logoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 60),
            logoImageView.widthAnchor.constraint(equalToConstant: 100),
            logoImageView.heightAnchor.constraint(equalToConstant: 100),
            
            // Title constraints
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Subtitle constraints
            subtitleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Login button constraints
            loginButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            loginButton.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 40),
            loginButton.widthAnchor.constraint(equalToConstant: Constants.UI.buttonWidth),
            loginButton.heightAnchor.constraint(equalToConstant: Constants.UI.buttonHeight),
            
            diagnosticButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            diagnosticButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 20),
            diagnosticButton.widthAnchor.constraint(equalToConstant: Constants.UI.buttonWidth),
            diagnosticButton.heightAnchor.constraint(equalToConstant: Constants.UI.buttonHeight),
            
            resultLabel.topAnchor.constraint(equalTo: diagnosticButton.bottomAnchor, constant: Constants.UI.spacing),
            resultLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.UI.padding),
            resultLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.UI.padding),
            resultLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.UI.spacing),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
    loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
    diagnosticButton.addTarget(self, action: #selector(diagnosticButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - MSAL Initialization
    private func initMSAL() {
        do {
            guard let authorityURL = URL(string: Constants.MSAL.authority) else {
                Logger.shared.error("❌ Invalid authority URL configuration: \(Constants.MSAL.authority)")
                showError(Constants.ErrorMessages.invalidAuthorityURL)
                return
            }
            
            Logger.shared.info("🔧 Initializing MSAL with authority: \(Constants.MSAL.authority)")
            Logger.shared.info("🔧 Client ID: \(Constants.MSAL.clientID)")
            Logger.shared.info("🔧 Redirect URI: \(Constants.MSAL.redirectUri)")
            
            let authority = try MSALAADAuthority(url: authorityURL)
            let msalConfig = MSALPublicClientApplicationConfig(
                clientId: Constants.MSAL.clientID,
                redirectUri: Constants.MSAL.redirectUri,
                authority: authority
            )
            
            applicationContext = try MSALPublicClientApplication(configuration: msalConfig)
            webViewParameters = MSALWebviewParameters(authPresentationViewController: self)
            
            // Configure webview parameters
            webViewParameters?.prefersEphemeralWebBrowserSession = false
            webViewParameters?.webviewType = .default
            
            Logger.shared.success("✅ MSAL initialized successfully")
        } catch {
            let errorMessage = String(format: Constants.ErrorMessages.msalInitFailed, error.localizedDescription)
            Logger.shared.error("❌ MSAL initialization failed: \(errorMessage)")
            Logger.shared.error("❌ Error details: \(error)")
            showError(errorMessage)
        }
    }
    
    // MARK: - Actions
    @objc private func loginButtonTapped() {
        Logger.shared.info("🔑 Login button tapped")
        
        guard let applicationContext = applicationContext, let webViewParameters = webViewParameters else {
            Logger.shared.error("❌ MSAL not properly initialized")
            Logger.shared.error("❌ Application Context: \(String(describing: applicationContext))")
            Logger.shared.error("❌ WebView Parameters: \(String(describing: webViewParameters))")
            showError(Constants.ErrorMessages.msalNotInitialized)
            return
        }
        
        setLoading(true)
        Logger.shared.info("🔑 Starting MSAL authentication")
        Logger.shared.info("🔑 Requested scopes: \(Constants.MSAL.scopes)")
        
        let parameters = MSALInteractiveTokenParameters(
            scopes: Constants.MSAL.scopes,
            webviewParameters: webViewParameters
        )
        
        // Configure additional parameters
        parameters.promptType = .selectAccount
        parameters.loginHint = nil
        
        Logger.shared.info("🔑 Acquiring token...")
        applicationContext.acquireToken(with: parameters) { [weak self] (result, error) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.setLoading(false)
                
                if let error = error {
                    Logger.shared.error("❌ Authentication failed: \(error.localizedDescription)")
                    Logger.shared.error("❌ Error details: \(error)")
                    self.handleMSALError(error)
                    return
                }
                
                guard let result = result else {
                    Logger.shared.error("❌ No authentication result received")
                    self.showError(Constants.ErrorMessages.noAuthResult)
                    return
                }
                
                Logger.shared.success("✅ Authentication successful")
                Logger.shared.info("👤 Username: \(result.account.username ?? "Unknown")")
                Logger.shared.info("🔑 Access Token: \(result.accessToken.prefix(10))...")
                Logger.shared.info("⏱️ Token Expires: \(result.expiresOn)")
                
                self.handleSuccessfulLogin(result)
            }
        }
    }
    
    @objc private func diagnosticButtonTapped() {
        Logger.shared.info("Opening Intune diagnostic console")
        Logger.shared.success("Test success message on diagnostic")
        Logger.shared.warning("Test warning message on diagnostic")
        Logger.shared.error("Test error message on diagnostic")
        IntuneMAMDiagnosticConsole.display()
    }
    
    // MARK: - Helper Methods
    private func setLoading(_ isLoading: Bool) {
        loginButton.isEnabled = !isLoading
        loginButton.alpha = isLoading ? 0.5 : 1.0
        isLoading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        Logger.shared.info(isLoading ? "Loading started" : "Loading finished")
    }
    
    private func showError(_ message: String) {
        Logger.shared.error("Error displayed: \(message)")
        resultLabel.text = "Error: \(message)"
        resultLabel.textColor = .systemRed
    }
    
    private func handleMSALError(_ error: Error) {
        Logger.shared.error("MSAL error: \(error.localizedDescription)")
        
        // Use string comparison on the error description to identify error types
        let errorString = error.localizedDescription.lowercased()
        
        if errorString.contains("user canceled") || errorString.contains("user cancelled") {
            Logger.shared.warning("User canceled authentication")
            showError(Constants.ErrorMessages.loginCancelled)
        } else if errorString.contains("no broker") || errorString.contains("broker application") {
            Logger.shared.error("No broker application available")
            #if targetEnvironment(simulator)
            showError("Authentication failed: Please test on a physical device for broker authentication")
            #else
            showError("Authentication failed: Microsoft Authenticator app is required. Please install it from the App Store.")
            #endif
        } else if errorString.contains("did not receive response from broker") {
            Logger.shared.error("Broker response timeout")
            showError("Authentication failed: Microsoft Authenticator app did not respond. Please ensure it's installed and you're signed in.")
        } else {
            // Generic MSAL error
            Logger.shared.error("MSAL error details: \(error)")
            showError(String(format: Constants.ErrorMessages.authFailed, error.localizedDescription))
        }
    }
    
    private func handleSuccessfulLogin(_ result: MSALResult) {
        let username = result.account.username ?? "Unknown"
        Logger.shared.success("Login successful for user: \(username)")
        
        // Navigate to PostEnrollmentViewController
        let postEnrollmentVC = PostEnrollmentViewController()
        postEnrollmentVC.modalPresentationStyle = .fullScreen
        present(postEnrollmentVC, animated: true)
        
        // Start Intune enrollment
        enrollWithIntune(identity: username, account: result.account, accessToken: result.accessToken)
    }
    
    private func enrollWithIntune(identity: String, account: MSALAccount, accessToken: String) {
        let enrollmentManager = IntuneMAMEnrollmentManager.instance()
        let policyManager = IntuneMAMPolicyManager.instance()
        
        Logger.shared.info("📱 Starting Intune enrollment process")
        Logger.shared.info("👤 Identity: \(identity)")
        Logger.shared.info("🔑 Access Token: \(accessToken.prefix(10))...")
        
        // Check if already enrolled
        if policyManager.isManagementEnabled() {
            Logger.shared.success("✅ Device is already enrolled with Intune")
            Logger.shared.info("📱 Management Status: Enabled")
            resultLabel.text = "✅ \(Constants.Text.enrollmentSuccess)"
            resultLabel.textColor = .systemGreen
            return
        }
        
        Logger.shared.info("📱 Device not enrolled, starting enrollment...")
        resultLabel.text = "\(Constants.Text.enrolling)\nPlease wait..."
        resultLabel.textColor = .systemBlue
        
        // Remove existing observers first to avoid duplicates
        NotificationCenter.default.removeObserver(self)
        
        // Add observers before starting enrollment
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleEnrollmentStatus),
            name: Notification.Name("IntuneEnrollmentSucceeded"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleEnrollmentError),
            name: Notification.Name("IntuneEnrollmentFailed"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleEnrollmentStatusChange),
            name: Notification.Name("IntuneEnrollmentStatusChanged"),
            object: nil
        )
        
        Logger.shared.info("📱 Registering and enrolling account...")
        enrollmentManager.registerAndEnrollAccountId(account.username ?? "")
    }
    
    @objc private func handleEnrollmentStatus() {
        Logger.shared.success("✅ Intune enrollment succeeded")
        Logger.shared.info("📱 Device is now managed by Intune")
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.resultLabel.text = "✅ \(Constants.Text.enrollmentSuccess)"
            self.resultLabel.textColor = .systemGreen
        }
    }
    
    @objc private func handleEnrollmentError(_ notification: Notification) {
        Logger.shared.error("❌ Intune enrollment failed")
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let error = notification.userInfo?["error"] as? Error {
                Logger.shared.error("❌ Enrollment error: \(error.localizedDescription)")
                Logger.shared.error("❌ Error details: \(error)")
                
                // Check for specific error cases
                if error.localizedDescription.contains("AAD token") {
                    Logger.shared.error("❌ Authentication token issue detected")
                    self.resultLabel.text = "❌ Authentication required. Please login again."
                    self.resultLabel.textColor = .systemRed
                } else {
                    self.resultLabel.text = "❌ \(Constants.Text.enrollmentFailed): \(error.localizedDescription)"
                    self.resultLabel.textColor = .systemRed
                }
            } else {
                Logger.shared.error("❌ Enrollment failed with unknown error")
                self.resultLabel.text = "❌ \(Constants.Text.enrollmentFailed): Unknown error occurred"
                self.resultLabel.textColor = .systemRed
            }
        }
    }
    
    @objc private func handleEnrollmentStatusChange(_ notification: Notification) {
        Logger.shared.info("📱 Enrollment status change notification received")
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.resultLabel.text = "📱 Enrollment in progress..."
            self.resultLabel.textColor = .systemYellow
        }
    }
    
    deinit {
        Logger.shared.info("ViewController deinitialized")
        NotificationCenter.default.removeObserver(self)
    }
}
