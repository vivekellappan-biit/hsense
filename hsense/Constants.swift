import UIKit

enum Constants {
   
    enum UI {
        static let buttonHeight: CGFloat = 50
        static let buttonWidth: CGFloat = 250
        static let cornerRadius: CGFloat = 8
        static let padding: CGFloat = 20
        static let spacing: CGFloat = 30
    }
    
    
    enum MSAL {
        static let clientID = "e9134e72-b929-4b88-a44e-2dac32d9e39c"
        static let redirectUri = "msauth.com.app.hsense://auth"
        static let authority = "https://login.microsoftonline.com/common"
        static let scopes = ["User.Read"]
    }
    
   
    enum Text {
        static let loginButtonTitle = "Login with Microsoft"
        static let loginSuccess = "Login Successful"
        static let userInfo = "User Information"
        static let tokenInfo = "Token Information"
        static let enrolling = "Enrolling with Intune..."
        static let enrollmentSuccess = "Successfully enrolled with Intune"
        static let enrollmentFailed = "Intune enrollment failed"
        static let alreadyEnrolled = "Device is already enrolled with Intune"
    }
    
   
    enum ErrorMessages {
        static let invalidAuthorityURL = "Invalid authority URL configuration"
        static let msalInitFailed = "Failed to initialize MSAL: %@"
        static let msalNotInitialized = "MSAL not properly initialized. Please restart the app."
        static let noAuthResult = "No authentication result received"
        static let loginCancelled = "Login was cancelled by the user"
        static let noBrokerApp = "No broker application available for authentication"
        static let networkError = "Network error occurred. Please check your connection"
        static let authFailed = "Authentication failed: %@"
        static let unexpectedError = "An unexpected error occurred: %@"
    }
} 
