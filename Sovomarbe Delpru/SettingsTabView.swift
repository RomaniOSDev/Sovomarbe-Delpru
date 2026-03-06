//
//  SettingsTabView.swift
//  Sovomarbe Delpru
//

import SwiftUI
import StoreKit
import UIKit

struct SettingsTabView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.appBackground, .appSurface],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            Canvas { context, size in
                let center = CGPoint(x: size.width * 0.8, y: size.height * 0.15)
                let radius = min(size.width, size.height) * 0.45
                let rect = CGRect(x: center.x - radius,
                                  y: center.y - radius,
                                  width: radius * 2,
                                  height: radius * 2)
                context.fill(
                    Path(ellipseIn: rect),
                    with: .radialGradient(
                        .init(colors: [Color.appPrimary.opacity(0.22), .clear]),
                        center: .init(x: center.x / size.width, y: center.y / size.height),
                        startRadius: 0,
                        endRadius: radius
                    )
                )
            }
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    appSection
                    linksSection
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
                .frame(maxWidth: 390)
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Settings")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.appTextSecondary)
            Text("Fine-tune how you interact with the mini games.")
                .font(.system(size: 14))
                .foregroundColor(.appTextSecondary)
        }
    }
    
    private var appSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("App")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.appTextSecondary)
            
            VStack(spacing: 10) {
                settingsRow(
                    title: "Rate this app",
                    subtitle: "Share your feedback on the App Store.",
                    systemImage: "star.bubble.fill",
                    action: rateApp
                )
            }
            .padding(14)
            .background(Color.appSurface)
            .cornerRadius(18)
            .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
        }
    }
    
    private var linksSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Legal")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.appTextSecondary)
            
            VStack(spacing: 10) {
                settingsRow(
                    title: "Privacy Policy",
                    subtitle: "How your data is handled.",
                    systemImage: "lock.shield.fill",
                    action: openPrivacy
                )
                settingsRow(
                    title: "Terms of Use",
                    subtitle: "Read the terms for using this app.",
                    systemImage: "doc.text.fill",
                    action: openTerms
                )
            }
            .padding(14)
            .background(Color.appSurface)
            .cornerRadius(18)
            .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
        }
    }
    
    private func settingsRow(title: String, subtitle: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.appPrimary.opacity(0.12))
                        .frame(width: 36, height: 36)
                    Image(systemName: systemImage)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.appPrimary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.appTextSecondary)
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(.appTextSecondary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                }
                
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.appTextSecondary.opacity(0.7))
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    private func openPrivacy() {
        if let url = URL(string: "https://sovomarbedelpru114.site/privacy/31") {
            UIApplication.shared.open(url)
        }
    }
    
    private func openTerms() {
        if let url = URL(string: "https://sovomarbedelpru114.site/terms/31") {
            UIApplication.shared.open(url)
        }
    }
    
    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}

#Preview {
    SettingsTabView()
}

