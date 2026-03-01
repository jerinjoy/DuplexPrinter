//
//  ContentView.swift
//  DuplexPrinter
//
//  Created by Jerin Joy & Noel Joy on 2026.
//  Copyright © 2026 Jerin Joy & Noel Joy. All rights reserved.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var selectedFileURL: URL?
    @State private var documentPageCount: Int = 0
    @State private var errorMessage: String?
    @State private var isHovering = false
    @State private var showingFileImporter = false

    var body: some View {
        VStack(spacing: 30) {
            Text("Duplex Printer")
                .font(.system(size: 32, weight: .bold))

            if let url = selectedFileURL {
                VStack(spacing: 8) {
                    Image(systemName: "doc.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.accentColor)
                    Text(url.lastPathComponent)
                        .font(.headline)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    Text("\(documentPageCount) Pages")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.secondary.opacity(0.1)))

                HStack(spacing: 20) {
                    Button(action: printOddPages) {
                        VStack(spacing: 8) {
                            Image(systemName: "printer.fill")
                                .font(.title)
                            Text("1. Print Odd Pages")
                                .fontWeight(.semibold)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)

                    Button(action: printEvenPagesReversed) {
                        VStack(spacing: 8) {
                            Image(systemName: "printer.fill.and.paper.fill")
                                .font(.title)
                            Text("2. Print Even Pages")
                                .fontWeight(.semibold)
                            Text("(Reversed)")
                                .font(.caption)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }

                Button("Choose Different File") {
                    selectedFileURL = nil
                    documentPageCount = 0
                }
                .buttonStyle(.plain)
                .foregroundColor(.blue)
                .padding(.top, 10)

            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(
                            style: StrokeStyle(lineWidth: 2, dash: [10])
                        )
                        .foregroundColor(isHovering ? .accentColor : .gray)
                        .background(isHovering ? Color.accentColor.opacity(0.1) : Color.clear)

                    VStack(spacing: 12) {
                        Image(systemName: "arrow.down.doc")
                            .font(.system(size: 48))
                            .foregroundColor(isHovering ? .accentColor : .gray)
                        Text("Drag & Drop PDF here")
                            .font(.title3)
                            .fontWeight(.medium)
                        Text("or click to select file")
                            .foregroundColor(.secondary)
                    }
                }
                .frame(width: 400, height: 260)
                .onDrop(of: [.fileURL], isTargeted: $isHovering) { providers in
                    return handleDrop(providers: providers)
                }
                .onTapGesture {
                    showingFileImporter = true
                }
            }

            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
        .padding(40)
        .frame(minWidth: 500, minHeight: 450)
        .fileImporter(isPresented: $showingFileImporter, allowedContentTypes: [.pdf], allowsMultipleSelection: false) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    loadFile(url: url)
                }
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }

    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else { return false }
        provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, error in
            DispatchQueue.main.async {
                if let data = item as? Data,
                   let url = URL(dataRepresentation: data, relativeTo: nil) {
                    if url.pathExtension.lowercased() == "pdf" {
                        self.loadFile(url: url)
                        return
                    }
                } else if let url = item as? URL {
                    if url.pathExtension.lowercased() == "pdf" {
                        self.loadFile(url: url)
                        return
                    }
                }
                self.errorMessage = "Please select a valid PDF file."
            }
        }
        return true
    }

    private func loadFile(url: URL) {
        if PrintManager.shared.loadPDF(url: url) {
            self.selectedFileURL = url
            self.documentPageCount = PrintManager.shared.pageCount ?? 0
            self.errorMessage = nil
        } else {
            self.errorMessage = "Failed to load PDF."
        }
    }

    private func printOddPages() {
        guard PrintManager.shared.hasPDF else { return }
        do {
            try PrintManager.shared.printOddPages()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func printEvenPagesReversed() {
        guard PrintManager.shared.hasPDF else { return }
        do {
            try PrintManager.shared.printEvenPagesReversed()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
