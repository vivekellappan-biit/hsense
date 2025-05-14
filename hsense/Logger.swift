import UIKit

class Logger {
    static let shared = Logger()
    
    private var logView: LogView?
    private weak var window: UIWindow?
    
    private init() {
        // We'll set the window later when it's available
    }
    
    func setWindow(_ window: UIWindow) {
        self.window = window
    }
    
    func getLogView() -> LogView? {
        return logView
    }
    
    func setup() {
        guard let window = window else {
            print("Logger setup failed: No window available")
            return
        }
        
        // Remove existing log view if any
        logView?.removeFromSuperview()
        
        let logView = LogView(frame: CGRect(x: 20, y: 100, width: 300, height: 200))
        logView.layer.cornerRadius = 8
        logView.clipsToBounds = true
        logView.alpha = 1.0
        logView.backgroundColor = .black.withAlphaComponent(0.8)
        window.addSubview(logView)
        
        // Ensure the log view is on top
        window.bringSubviewToFront(logView)
        
        self.logView = logView
        
        // Add initial test message
        log("Logger initialized", type: .success)
    }
    
    func log(_ message: String, type: LogType = .info) {
        DispatchQueue.main.async {
            self.logView?.log(message, type: type)
        }
    }
    
    func info(_ message: String) {
        log(message, type: .info)
    }
    
    func success(_ message: String) {
        log(message, type: .success)
    }
    
    func warning(_ message: String) {
        log(message, type: .warning)
    }
    
    func error(_ message: String) {
        log(message, type: .error)
    }
} 