import SwiftUI

struct DigitalFontView: View {
    private let samples: [Sample] = [
        Sample(title: "Timer", value: "12:34", size: 100, color: .green),
        Sample(title: "Rounds", value: "RND 05", size: 60, color: .yellow),
        Sample(title: "Status", value: "PAUSED", size: 48, color: .orange),
        Sample(title: "Elapsed", value: "00:59", size: 72, color: .red)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Digital Font Showcase")
                    .font(.title.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("The DS-Digital typeface keeps the timer easy to read from a distance. These examples demonstrate how the custom digitalFont(size:) modifier can be applied with different colors and sizes.")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.7))
                    .frame(maxWidth: .infinity, alignment: .leading)

                ForEach(samples) { sample in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(sample.title.uppercased())
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))

                        Text(sample.value)
                            .digitalFont(size: sample.size)
                            .foregroundColor(sample.color)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Usage")
                        .font(.headline)
                        .foregroundColor(.white)

                    Text("Apply the modifier to any text element to match the primary clock interface.")
                        .foregroundColor(.white.opacity(0.7))

                    Text("Text(\"12:34\")\n    .digitalFont(size: 80)\n    .foregroundColor(.green)")
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.white.opacity(0.9))
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                }

                Spacer(minLength: 12)
            }
            .padding(24)
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .navigationTitle("Digital Font")
    }
}

private struct Sample: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let size: CGFloat
    let color: Color
}
