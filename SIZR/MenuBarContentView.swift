import AppKit
import SwiftUI

struct MenuBarContentView: View {
    @ObservedObject var viewModel: MenuBarViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            header

            if !viewModel.isAccessibilityTrusted {
                accessibilityCallout
            }

            Button("Resize to \(WindowSize.hd.dimensionsText)") {
                Task {
                    await viewModel.resizeToHD()
                }
            }

            Button("Custom...") {
                viewModel.revealCustomSizeControls()
            }

            if viewModel.isShowingCustomSizeControls {
                customSizeControls
            }

            Toggle(
                "Launch at login",
                isOn: Binding(
                    get: { viewModel.isLaunchAtLoginEnabled },
                    set: { viewModel.setLaunchAtLoginEnabled($0) }
                )
            )

            if let status = viewModel.status {
                Text(status.message)
                    .font(.footnote)
                    .foregroundStyle(statusColor(for: status.tone))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Divider()

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding(16)
        .frame(width: 320)
        .onAppear {
            viewModel.prepareForDisplay()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("SIZR")
                .font(.headline)
            Text("Resize windows exactly")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var accessibilityCallout: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Accessibility access is required to resize windows.")
                .font(.footnote)
                .foregroundStyle(.secondary)

            Button("Grant Access") {
                viewModel.requestAccessibilityAccess()
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(nsColor: .windowBackgroundColor))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.secondary.opacity(0.25), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var customSizeControls: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Width")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("1920", text: $viewModel.customWidthText)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 110)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Height")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("1080", text: $viewModel.customHeightText)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 110)
                }
            }

            if let validationMessage = viewModel.customValidationMessage {
                Text(validationMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }

            Button("Apply") {
                Task {
                    await viewModel.applyCustomSize()
                }
            }
            .disabled(!viewModel.canApplyCustomSize)
        }
    }

    private func statusColor(for tone: StatusTone) -> Color {
        switch tone {
        case .success:
            return .green
        case .error:
            return .red
        case .info:
            return .secondary
        }
    }
}
