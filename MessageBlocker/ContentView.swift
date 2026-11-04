import SwiftUI

struct ContentView: View {
    @State private var keywords: [String] = KeywordStore.load()
    @State private var newKeyword: String = ""
    @State private var block0850: Bool = KeywordStore.isBlocking0850()
    @FocusState private var inputFocused: Bool

    private var trimmedInput: String {
        newKeyword.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var activeRuleCount: Int {
        keywords.count + (block0850 ? 1 : 0)
    }

    private var isDuplicate: Bool {
        !trimmedInput.isEmpty && keywords.contains { $0.caseInsensitiveCompare(trimmedInput) == .orderedSame }
    }

    var body: some View {
        ZStack {
            BackgroundGradient()

            ScrollView {
                VStack(spacing: 20) {
                    header
                    statusCard
                    numberRuleCard
                    addCard
                    rulesCard
                    footerNote
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 40)
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }

    // MARK: - Başlık

    private var header: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.accentBlue, Color.accentViolet],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 76, height: 76)
                    .shadow(color: Color.accentViolet.opacity(0.35), radius: 16, y: 8)

                Image(systemName: "shield.lefthalf.filled")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(.white)
            }

            Text("MessageBlocker")
                .font(.system(size: 28, weight: .bold, design: .rounded))

            Text("İstenmeyen mesajları sen görmeden ayıklar")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 8)
    }

    // MARK: - Durum kartı

    private var statusCard: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.accentBlue.opacity(0.15))
                    .frame(width: 46, height: 46)
                Image(systemName: "line.3.horizontal.decrease.circle.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(Color.accentBlue)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("\(activeRuleCount) kural aktif")
                    .font(.headline)
                Text(activeRuleCount == 0
                     ? "Henüz hiçbir mesaj engellenmiyor"
                     : "Eşleşen mesajlar İstenmeyen'e taşınır")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .cardStyle()
    }

    // MARK: - Numara kuralı

    private var numberRuleCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Numara kuralı", systemImage: "phone.down")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            Toggle(isOn: $block0850) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("0850 ile başlayan numaralar")
                        .font(.body.weight(.medium))
                    Text("Bu numaralardan gelen SMS'ler engellenir")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .tint(Color.accentBlue)
            .onChange(of: block0850) { _, newValue in
                KeywordStore.setBlocking0850(newValue)
            }

        }
        .padding(16)
        .cardStyle()
    }

    // MARK: - Kelime ekleme

    private var addCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Yeni kelime ekle", systemImage: "plus.circle")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            HStack(spacing: 10) {
                TextField("örn. metin2", text: $newKeyword)
                    .textFieldStyle(.plain)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .focused($inputFocused)
                    .submitLabel(.done)
                    .onSubmit(addKeyword)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.fieldBackground)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(inputFocused ? Color.accentBlue.opacity(0.6) : Color.clear, lineWidth: 1.5)
                    )

                Button(action: addKeyword) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.accentBlue, Color.accentViolet],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                }
                .disabled(trimmedInput.isEmpty || isDuplicate)
                .opacity(trimmedInput.isEmpty || isDuplicate ? 0.4 : 1)
            }

            if isDuplicate {
                Label("Bu kelime zaten listede", systemImage: "exclamationmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)
                    .transition(.opacity)
            }
        }
        .padding(16)
        .cardStyle()
        .animation(.easeInOut(duration: 0.2), value: isDuplicate)
    }

    // MARK: - Kural listesi

    private var rulesCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Engellenen kelimeler", systemImage: "nosign")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            if keywords.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "tray")
                        .font(.system(size: 28))
                        .foregroundStyle(.tertiary)
                    Text("Henüz kural eklenmedi")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
            } else {
                FlowLayout(spacing: 8) {
                    ForEach(keywords, id: \.self) { keyword in
                        KeywordChip(text: keyword) {
                            delete(keyword)
                        }
                    }
                }
            }
        }
        .padding(16)
        .cardStyle()
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: keywords)
    }

    // MARK: - Alt bilgi

    private var footerNote: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(Color.accentBlue)
            Text("Filtreleme yalnızca bilinmeyen numaralardan gelen SMS'lerde çalışır. Ayarlar yolunu README'de bulabilirsin.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.accentBlue.opacity(0.08))
        )
    }

    // MARK: - İşlemler

    private func addKeyword() {
        let trimmed = trimmedInput
        guard !trimmed.isEmpty, !isDuplicate else { return }
        keywords.append(trimmed)
        KeywordStore.save(keywords)
        newKeyword = ""
    }

    private func delete(_ keyword: String) {
        keywords.removeAll { $0 == keyword }
        KeywordStore.save(keywords)
    }
}

// MARK: - Kelime etiketi

private struct KeywordChip: View {
    let text: String
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 6) {
            Text(text)
                .font(.subheadline.weight(.medium))
                .lineLimit(1)

            Button(action: onDelete) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.secondary)
                    .frame(width: 18, height: 18)
                    .background(Circle().fill(Color.chipClose))
            }
            .buttonStyle(.plain)
        }
        .padding(.leading, 12)
        .padding(.trailing, 6)
        .padding(.vertical, 7)
        .background(
            Capsule().fill(Color.chipBackground)
        )
        .overlay(
            Capsule().stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
    }
}

// MARK: - Yardımcı görünümler

private struct BackgroundGradient: View {
    var body: some View {
        LinearGradient(
            colors: [Color.screenTop, Color.screenBottom],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

private struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.cardBackground)
                    .shadow(color: Color.black.opacity(0.06), radius: 12, y: 4)
            )
    }
}

private extension View {
    func cardStyle() -> some View { modifier(CardStyle()) }
}

private extension Color {
    static let accentBlue = Color(red: 0.25, green: 0.47, blue: 0.95)
    static let accentViolet = Color(red: 0.52, green: 0.33, blue: 0.93)

    static let screenTop = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.07, green: 0.07, blue: 0.10, alpha: 1)
            : UIColor(red: 0.96, green: 0.97, blue: 1.00, alpha: 1)
    })

    static let screenBottom = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.04, green: 0.04, blue: 0.06, alpha: 1)
            : UIColor(red: 0.93, green: 0.94, blue: 0.98, alpha: 1)
    })

    static let cardBackground = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.13, green: 0.13, blue: 0.16, alpha: 1)
            : .white
    })

    static let fieldBackground = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.18, green: 0.18, blue: 0.22, alpha: 1)
            : UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1)
    })

    static let chipBackground = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.20, green: 0.20, blue: 0.25, alpha: 1)
            : UIColor(red: 0.94, green: 0.95, blue: 0.98, alpha: 1)
    })

    static let chipClose = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.30, green: 0.30, blue: 0.36, alpha: 1)
            : UIColor(red: 0.86, green: 0.87, blue: 0.91, alpha: 1)
    })
}

// MARK: - Etiketleri satırlara saran yerleşim

private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var rowWidth: CGFloat = 0
        var rowHeight: CGFloat = 0
        var totalHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if rowWidth > 0, rowWidth + spacing + size.width > maxWidth {
                totalHeight += rowHeight + spacing
                rowWidth = size.width
                rowHeight = size.height
            } else {
                rowWidth += rowWidth > 0 ? spacing + size.width : size.width
                rowHeight = max(rowHeight, size.height)
            }
        }
        totalHeight += rowHeight

        return CGSize(width: maxWidth == .infinity ? rowWidth : maxWidth, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > bounds.minX, x + size.width > bounds.maxX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

#Preview {
    ContentView()
}
