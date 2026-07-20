import SwiftUI

struct ContentView: View {
    @State private var keywords: [String] = KeywordStore.load()
    @State private var newKeyword: String = ""

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        TextField("Örn: mt2, metin2, server", text: $newKeyword)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .onSubmit(addKeyword)
                        Button(action: addKeyword) {
                            Image(systemName: "plus.circle.fill")
                        }
                        .disabled(newKeyword.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                } header: {
                    Text("Yeni kelime ekle")
                } footer: {
                    Text("Mesaj içinde bu kelimelerden biri geçerse, mesaj sana bildirim olarak gösterilmeden İstenmeyen klasörüne taşınır.")
                }

                Section("Kurallar") {
                    if keywords.isEmpty {
                        Text("Henüz kural eklenmedi.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(keywords, id: \.self) { keyword in
                            Text(keyword)
                        }
                        .onDelete(perform: deleteKeywords)
                    }
                }
            }
            .navigationTitle("MessageBlocker")
            .toolbar { EditButton() }
        }
    }

    private func addKeyword() {
        let trimmed = newKeyword.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !keywords.contains(where: { $0.caseInsensitiveCompare(trimmed) == .orderedSame }) else {
            newKeyword = ""
            return
        }
        keywords.append(trimmed)
        KeywordStore.save(keywords)
        newKeyword = ""
    }

    private func deleteKeywords(at offsets: IndexSet) {
        keywords.remove(atOffsets: offsets)
        KeywordStore.save(keywords)
    }
}

#Preview {
    ContentView()
}
