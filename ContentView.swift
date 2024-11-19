import SwiftUI

// MARK: - Content View
struct ContentView: View {
    @StateObject private var colorViewModel = ColorViewModel()

    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)

            VStack {
                Text("Color the Bear!")
                    .font(.largeTitle)
                    .padding(.top, 20)

                BearCanvasView(selectedColor: $colorViewModel.selectedColor)
                    .frame(height: UIScreen.main.bounds.height * 0.6)
                    .background(Color.gray.opacity(0.2)) // Debug frame background

                Spacer()

                ColorPanelView(selectedColor: $colorViewModel.selectedColor)
                    .padding(.bottom, 30)
            }
        }
    }
}

// MARK: - View Model
class ColorViewModel: ObservableObject {
    @Published var selectedColor: Color = .brown
}

// MARK: - Bear Canvas View
struct BearCanvasView: View {
    @Binding var selectedColor: Color

    // Separate grids for each part of the bear
    @State private var headGrid: [[Color]] = Array(repeating: Array(repeating: .brown, count: 8), count: 8)
    @State private var earGrid: [[Color]] = Array(repeating: Array(repeating: .brown, count: 4), count: 4)
    @State private var bodyGrid: [[Color]] = Array(repeating: Array(repeating: .brown, count: 10), count: 6)
    @State private var legGrid: [[Color]] = Array(repeating: Array(repeating: .brown, count: 3), count: 4)

    var body: some View {
        GeometryReader { geometry in
            let gridSize = geometry.size.width / 30 // Adjust grid size for aesthetics

            VStack(spacing: gridSize / 10) {
                // Ears
                HStack(spacing: gridSize / 2) {
                    PixelGridView(grid: $earGrid, pixelSize: gridSize, selectedColor: $selectedColor)
                    PixelGridView(grid: $earGrid, pixelSize: gridSize, selectedColor: $selectedColor)
                }
                .offset(y: -gridSize)

                // Head
                PixelGridView(grid: $headGrid, pixelSize: gridSize, selectedColor: $selectedColor)

                // Body
                PixelGridView(grid: $bodyGrid, pixelSize: gridSize, selectedColor: $selectedColor)

                // Legs
                HStack(spacing: gridSize / 2) {
                    PixelGridView(grid: $legGrid, pixelSize: gridSize, selectedColor: $selectedColor)
                    PixelGridView(grid: $legGrid, pixelSize: gridSize, selectedColor: $selectedColor)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: - Pixel Grid View
struct PixelGridView: View {
    @Binding var grid: [[Color]]
    let pixelSize: CGFloat
    @Binding var selectedColor: Color

    var body: some View {
        VStack(spacing: pixelSize / 10) {
            ForEach(0..<grid.count, id: \.self) { row in
                HStack(spacing: pixelSize / 10) {
                    ForEach(0..<grid[row].count, id: \.self) { col in
                        Rectangle()
                            .fill(grid[row][col])
                            .frame(width: pixelSize, height: pixelSize)
                            .onTapGesture {
                                floodFill(row: row, col: col, targetColor: grid[row][col])
                            }
                    }
                }
            }
        }
    }

    // MARK: - Flood-Fill Algorithm
    private func floodFill(row: Int, col: Int, targetColor: Color) {
        guard row >= 0, row < grid.count, col >= 0, col < grid[row].count else { return } // Boundary check
        guard grid[row][col] == targetColor, targetColor != selectedColor else { return } // Only fill matching target color

        // Update the current pixel
        grid[row][col] = selectedColor

        // Recursively fill adjacent pixels
        floodFill(row: row + 1, col: col, targetColor: targetColor) // Down
        floodFill(row: row - 1, col: col, targetColor: targetColor) // Up
        floodFill(row: row, col: col + 1, targetColor: targetColor) // Right
        floodFill(row: row, col: col - 1, targetColor: targetColor) // Left
    }
}

// MARK: - Color Panel View
struct ColorPanelView: View {
    @Binding var selectedColor: Color

    private let colors: [Color] = [
        .brown, .red, .orange, .yellow, .green, .blue, .purple
    ]

    var body: some View {
        HStack(spacing: 15) {
            ForEach(colors, id: \.self) { color in
                ColorButton(color: color, isSelected: selectedColor == color) {
                    selectedColor = color
                }
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Color Button View
struct ColorButton: View {
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Circle()
                .fill(color)
                .frame(width: 40, height: 40)
                .overlay(
                    Circle()
                        .stroke(Color.black, lineWidth: isSelected ? 3 : 0)
                )
                .shadow(radius: isSelected ? 5 : 2)
        }
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

