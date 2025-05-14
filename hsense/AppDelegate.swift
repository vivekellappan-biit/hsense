import UIKit
import CoreData
import MSAL
import IntuneMAMSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate, IntuneMAMPolicyDelegate, IntuneMAMEnrollmentDelegate {
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Initialize logger
        Logger.shared.setup()
        Logger.shared.info("App launched")
        
        setupIntuneMAM()
        return true
    }
    
    private func setupIntuneMAM() {
        Logger.shared.info("Setting up Intune MAM...")
        
        // Initialize Intune MAM first
        IntuneMAMEnrollmentManager.initialize()
        IntuneMAMPolicyManager.instance().delegate = self
        IntuneMAMEnrollmentManager.instance().delegate = self
        
        // Register for notifications
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
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleEnrollmentCanceled),
            name: Notification.Name("IntuneEnrollmentCanceled"),
            object: nil
        )
        
        // Print initial enrollment status
        let policyManager = IntuneMAMPolicyManager.instance()
        let status = policyManager.isManagementEnabled() ? "Enabled" : "Disabled"
        Logger.shared.info("Initial Intune management status: \(status)")
    }
    
    @objc private func handleEnrollmentSucceeded() {
        Logger.shared.success("✅ Intune enrollment succeeded")
    }
    
    @objc private func handleEnrollmentFailed(_ notification: Notification) {
        if let error = notification.userInfo?["error"] as? Error {
            Logger.shared.error("❌ Intune enrollment failed: \(error.localizedDescription)")
        }
    }
    
    @objc private func handleEnrollmentCanceled() {
        Logger.shared.warning("ℹ️ Intune enrollment canceled by user")
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        Logger.shared.info("Handling URL: \(url.absoluteString)")
        return MSALPublicClientApplication.handleMSALResponse(url, sourceApplication: options[.sourceApplication] as? String)
    }
    
    func enrollmentRequest(with status: IntuneMAMEnrollmentStatus) {
        if status.didSucceed {
            Logger.shared.success("✅ Intune enrollment successful for identity: \(status.identity)")
            NotificationCenter.default.post(name: Notification.Name("IntuneEnrollmentSucceeded"), object: nil)
        } else if IntuneMAMEnrollmentStatusCode.loginCanceled == status.statusCode {
            Logger.shared.warning("ℹ️ Intune enrollment was canceled by the user")
            NotificationCenter.default.post(name: Notification.Name("IntuneEnrollmentCanceled"), object: nil)
        } else {
            let errorMessage = "❌ Enrollment failed for identity \(status.identity ?? "Unknown") with status code \(status.statusCode)"
            Logger.shared.error(errorMessage)
            Logger.shared.error("Debug message: \(String(describing: status.errorString))")
            
            let enrollmentError = NSError(domain: "IntuneEnrollment", code: Int(status.statusCode.rawValue), userInfo: [
                NSLocalizedDescriptionKey: status.errorString ?? "Unknown error during Intune enrollment"
            ])
            
            NotificationCenter.default.post(name: Notification.Name("IntuneEnrollmentFailed"),
                                           object: nil,
                                           userInfo: ["error": enrollmentError])
        }
    }

    func policyRequest(with status: IntuneMAMEnrollmentStatus) {
        Logger.shared.info("Policy check-in result for identity \(status.accountId) with status code \(status.statusCode)")
        if let errorMessage = status.errorString {
            Logger.shared.error("Debug Message: \(errorMessage)")
        }
    }

    func unenrollRequest(with status: IntuneMAMEnrollmentStatus) {
        Logger.shared.info("Un-enroll result for identity \(status.accountId) with status code \(status.statusCode)")
        if let errorMessage = status.errorString {
            Logger.shared.error("Debug Message: \(errorMessage)")
        }
    }
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "hsense")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                Logger.shared.error("Core Data store error: \(error.localizedDescription)")
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
                Logger.shared.success("Core Data context saved successfully")
            } catch {
                let nserror = error as NSError
                Logger.shared.error("Core Data save error: \(nserror.localizedDescription)")
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}



