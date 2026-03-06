//
//  ContentView.swift
//  Sovomarbe Delpru
//
//  Created by Роман Главацкий on 05.03.2026.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appStorage: AppStorageManager
    
    var body: some View {
        Group {
            if appStorage.hasSeenOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: appStorage.hasSeenOnboarding)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppStorageManager.shared)
}
