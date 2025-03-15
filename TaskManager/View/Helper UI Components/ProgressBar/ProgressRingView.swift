//
//  ProgressRingView.swift
//  TaskManager
//
//  Created by Ammar Ul Haq on 12/03/2025.
//

import Foundation
import SwiftUI


struct ProgressRingView: View {
    let progress: Double // Value between 0.0 and 1.0
    let lineWidth: CGFloat = 12
    let size: CGFloat = 250

    var body: some View {
        ZStack {
            // Background circle (gray)
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: lineWidth)
                .frame(width: size, height: size)

            // Progress circle (blue)
            Circle()
                .trim(from: 0.0, to: progress)
                .stroke(Color.blue, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90)) // Start from the top
                .frame(width: size, height: size)
                .animation(.easeInOut(duration: 0.5), value: progress) // Smooth animation

            // Percentage text
            Text("Completed Tasks \n \(Int(progress * 100))%")
                .font(.headline)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
        }
    }
}
