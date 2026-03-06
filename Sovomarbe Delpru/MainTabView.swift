//
//  MainTabView.swift
//  Sovomarbe Delpru
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedIndex: Int = 0
    
    var body: some View {
        ZStack {
            Group {
                switch selectedIndex {
                case 0: HomeTabView()
                case 1: ActivitiesTabView()
                case 2: AchievementsTabView()
                default: SettingsTabView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .safeAreaInset(edge: .bottom) {
            TabBar(selectedIndex: $selectedIndex)
        }
        .ignoresSafeArea(.keyboard)
    }
}

private struct TabBar: View {
    @Binding var selectedIndex: Int
    
    var body: some View {
        HStack(spacing: 0) {
            TabBarItem(
                icon: "house.fill",
                title: "Home",
                index: 0,
                selectedIndex: $selectedIndex
            )
            TabBarItem(
                icon: "square.grid.2x2.fill",
                title: "Activities",
                index: 1,
                selectedIndex: $selectedIndex
            )
            TabBarItem(
                icon: "rosette",
                title: "Achievements",
                index: 2,
                selectedIndex: $selectedIndex
            )
            TabBarItem(
                icon: "gearshape.fill",
                title: "Settings",
                index: 3,
                selectedIndex: $selectedIndex
            )
        }
        .padding(.horizontal, 8)
        .padding(.top, 8)
        .padding(.bottom, 20)
        .background(
            Color.appSurface
                .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: -2)
        )
    }
}

private struct TabBarItem: View {
    let icon: String
    let title: String
    let index: Int
    @Binding var selectedIndex: Int
    
    var isSelected: Bool { index == selectedIndex }
    
    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedIndex = index
            }
        } label: {
            VStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(isSelected ? .appPrimary : .appTextSecondary)
                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(isSelected ? .appPrimary : .appTextSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity, minHeight: 44)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppStorageManager.shared)
}

