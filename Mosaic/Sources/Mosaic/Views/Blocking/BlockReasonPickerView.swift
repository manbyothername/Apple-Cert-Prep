import SwiftUI

struct BlockReasonPickerView: View {
    @ObservedObject var viewModel: BlockViewModel
    let currentUserId: String
    var onBlocked: (() -> Void)? = nil
    @State private var selectedReason: BlockReason? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                Color.mosaicBackground.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Why are you blocking?")
                            .font(.title3.bold())
                        Text("Select a reason so we can maintain a respectful community. Blocking without a reason adds an accountability flag to your profile that others can see.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)

                    VStack(spacing: 0) {
                        ForEach(BlockReason.allCases, id: \.self) { reason in
                            Button {
                                selectedReason = reason
                            } label: {
                                HStack {
                                    Text(reason.displayName)
                                        .foregroundStyle(.primary)
                                    Spacer()
                                    Image(systemName: selectedReason == reason ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(selectedReason == reason ? Color.mosaicAccent : .secondary)
                                }
                                .padding()
                                .background(Color.mosaicSurface)
                            }
                            Divider().background(Color.mosaicBackground)
                        }
                    }
                    .cornerRadius(12)
                    .padding(.horizontal)

                    Spacer()

                    VStack(spacing: 12) {
                        Button {
                            Task {
                                await viewModel.confirmBlock(
                                    reason: selectedReason,
                                    blockerId: currentUserId,
                                    onBlocked: onBlocked
                                )
                            }
                        } label: {
                            Group {
                                if viewModel.isBlocking {
                                    ProgressView().tint(.white)
                                } else {
                                    Text(selectedReason == nil
                                         ? "Block Without Reason (adds flag)"
                                         : "Confirm Block")
                                    .frame(maxWidth: .infinity)
                                }
                            }
                        }
                        .buttonStyle(MosaicDestructiveButtonStyle())
                        .disabled(viewModel.isBlocking)

                        Button("Cancel") { viewModel.dismiss() }
                            .foregroundStyle(Color.mosaicAccent)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
                .padding(.top, 24)
            }
            .navigationTitle("Block")
            .navigationBarTitleDisplayMode(.inline)
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }
}
