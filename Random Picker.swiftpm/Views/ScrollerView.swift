//
//  ScrollerView.swift
//  SwiftUITests
//
//  Created by Vincent C. on 4/29/24.
//

import SwiftUI

func mod(_ a: Int, _ n: Int) -> Int {
    let remainder = a % n
    return remainder >= 0 ? remainder : remainder + n
}

struct ScrollItem: Identifiable {
    var id = UUID()
    var title: String
}

struct ScrollerView: View {
    static let scrollDurationPerItem = ContinuousClock.Duration.milliseconds(80)
    
    @Binding var animating: Bool
    let items: [ScrollItem]
    var debugMode = false
    
    @State private var index: Int = 0
    @State private var rotation: Int = 0
    
    private let projectionRadius = 4
    
    private var rotationCount: Int {
        Int(ceil(Double(projectionRadius) / Double(items.count))) * 3
    }
    
    private var dataWithID: [(Int, String)] {
        (0 ..< rotationCount).flatMap { rotation in
            items.indices.map { i in
                (rotation * items.count + i, "\(i)-r\(rotation)")
            }
        }
    }
    
    private var segmentedData: [(Int, String)] {
        let spillOverLeft = max(0, projectionRadius - (rotation * items.count + index))
        let spillOverRight = max(0, projectionRadius - (dataWithID.count - 1 - (rotation * items.count + index)))
        let leftBoundary = max(0, rotation * items.count + index - projectionRadius)
        let rightBoundary = min(dataWithID.count, rotation * items.count + index + projectionRadius + 1)
        return Array(dataWithID.suffix(spillOverLeft)) + Array(dataWithID[leftBoundary ..< rightBoundary]) +
        Array(dataWithID.prefix(spillOverRight))
    }
    
    private struct ScrollerAnimatableDatum: Identifiable {
        var index: [ScrollItem].Index
        var delta: Double
        var id: String
    }
    
    private var normalizedData: [ScrollerAnimatableDatum] {
        segmentedData.indices.map { i in
            .init(
                index: segmentedData[i].0 % items.count,
                delta: Double(i - projectionRadius),
                id: segmentedData[i].1
            )
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                VStack(spacing: 0) {
                    if items.isEmpty {
                        Text("No items provided.")
                    } else {
                        ForEach(normalizedData) { datum in
                            let angle = datum.delta / Double(projectionRadius) * .pi / 2
                            let i = datum.index
                            Text(items[i].title + (debugMode ? " : \(datum.index)" : ""))
                                .padding(.vertical, 3)
                                .font(.title)
                                .scaleEffect(y: cos(angle))
                                .offset(y: (sin(datum.delta) - datum.delta) * 8)
                                .blur(radius: (1 - cos(angle)) * 4)
                                .opacity(0.2 + 0.8 * cos(angle))
                                .transition(.identity)
                        }
                    }
                }
                Spacer()
            }
            .overlay(alignment: .center) {
                HStack {
                    Spacer()
                    Text(" ")
                        .font(.title)
                    Spacer()
                }
                .padding(.vertical, 2)
                .background(.primary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .blur(radius: 1)
            }
            .animation(.smooth, value: index)
            
            if debugMode {
                HStack {
                    Button("up") {
                        index = mod(index - 1, items.count)
                        if index == items.count - 1 {
                            rotation = mod(rotation - 1, rotationCount)
                        }
                    }
                    Button("down") {
                        index = mod(index + 1, items.count)
                        if index == 0 {
                            rotation = mod(rotation + 1, rotationCount)
                        }
                    }
                }
                .buttonStyle(.bordered)
                Text("frame size: \(normalizedData.count)")
                HStack {
                    ForEach(normalizedData) {
                        Text("\($0.index)")
                            .transition(.identity)
                    }
                }
                .animation(.smooth, value: index)
            }
        }
        .task {
            while true {
                do {
                    try await Task.sleep(for: .milliseconds(80))
                } catch {
                    break
                }
                if animating {
                    index = mod(index + 1, items.count)
                    if index == 0 {
                        rotation = mod(rotation + 1, rotationCount)
                    }
                }
            }
        }
    }
}

fileprivate struct ScrollerTestView: View {
    @State private var animating: Bool = false
    @State private var debugMode: Bool = true
    
    var body: some View {
        VStack {
            ScrollerView(animating: $animating, items: [
                .init(title: "Alice"),
                .init(title: "Bob"),
                .init(title: "Charlie"),
                .init(title: "Delta"),
            ], debugMode: debugMode)
            Toggle("Animating", isOn: $animating)
            Toggle("Debug Mode", isOn: $debugMode)
        }
        .padding()
        .animation(.bouncy, value: debugMode)
    }
}

#Preview {
    ScrollerTestView()
}
