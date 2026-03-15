//
//  ContentView.swift
//  DuplexPrinter
//
//  Created by Jerin Joy & Noel Joy on 2026.
//  Copyright © 2026 Jerin Joy & Noel Joy. All rights reserved.
//

import SwiftUI
import UniformTypeIdentifiers

enum PrintStep {
    case fileSelection
    case printingOddPages
    case printingEvenPages
    case done
}

struct ContentView: View {
    @State private var selectedFileURL: URL?
    @State private var documentPageCount: Int = 0
    @State private var errorMessage: String?
    @State private var isHovering = false
    @State private var showingFileImporter = false
    @State private var currentStep: PrintStep = .fileSelection
    @State private var numberOfCopies: Int = 1
    @AppStorage("dryRunEnabled") private var dryRunEnabled = false

    var body: some View {
        VStack(spacing: 30) {
            Text("Duplex Printer")
                .font(.system(size: 32, weight: .bold))

            switch currentStep {
            case .fileSelection:
                fileSelectionView
            case .printingOddPages:
                printingOddPagesView
            case .printingEvenPages:
                printingEvenPagesView
            case .done:
                doneView
            }
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
        .padding(40)
        .frame(minWidth: 500, minHeight: 450)
        .background(dryRunEnabled ? Color.orange.opacity(0.15) : Color.clear)
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

    @ViewBuilder
    private var fileSelectionView: some View {
        VStack(spacing: 16) {
            Button(action: {
                showingFileImporter = true
            }) {
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
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .onDrop(of: [.fileURL], isTargeted: $isHovering) { providers in
                return handleDrop(providers: providers)
            }
            
            if dryRunEnabled {
                Button("Skip File Selection (Dry Run)") {
                    self.selectedFileURL = URL(fileURLWithPath: "/tmp/debug_file.pdf")
                    self.documentPageCount = 8
                    self.currentStep = .printingOddPages
                }
                .buttonStyle(.plain)
                .foregroundColor(.orange)
            }
        }
    }

    @ViewBuilder
    private var printingOddPagesView: some View {
        VStack(spacing: 20) {
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
            }

            VStack(spacing: 12) {
                Text("How many copies do you need?")
                    .font(.headline)
                HStack {
                    Stepper(value: $numberOfCopies, in: 1...100) {
                        EmptyView() // Label hidden for custom layout
                    }
                    .labelsHidden()
                    
                    Text("\(numberOfCopies) \(numberOfCopies == 1 ? "Copy" : "Copies")")
                        .frame(minWidth: 80, alignment: .leading)
                        .font(.title3)
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.accentColor.opacity(0.05)))

            Button(action: printOddPages) {
                VStack(spacing: 8) {
                    Image(systemName: "printer.fill")
                        .font(.title2)
                    Text("1. Print Odd Pages")
                        .fontWeight(.semibold)
                }
                .padding()
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)

            Button("Choose Different File") {
                selectedFileURL = nil
                documentPageCount = 0
                currentStep = .fileSelection
            }
            .buttonStyle(.plain)
            .foregroundColor(.secondary)
            .padding(.top, 10)
        }
    }

    @ViewBuilder
    private var printingEvenPagesView: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("Step 1 Complete")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                Text("Now, take the printed pages and load them back into the printer. Follow your printer's instructions for manual duplexing to ensure they are oriented correctly.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            }

            // Using SF Symbols for a mock animation view since we don't have custom assets
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.orange.opacity(0.1))
                VStack(spacing: 15) {
                    Image(systemName: "arrow.uturn.down.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)
                    Text("Flip the paper short-edge or long-edge according to your printer, then insert face up/down.")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()
            }
            .frame(height: 140)

            Button(action: printEvenPagesReversed) {
                VStack(spacing: 8) {
                    Image(systemName: "printer.fill.and.paper.fill")
                        .font(.title2)
                    Text("2. Print Even Pages")
                        .fontWeight(.semibold)
                    Text("(Reversed)")
                        .font(.caption)
                }
                .padding()
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)

            Button("Go Back") {
                currentStep = .printingOddPages
            }
            .buttonStyle(.plain)
            .foregroundColor(.secondary)
            .padding(.top, 10)
        }
    }

    @ViewBuilder
    private var doneView: some View {
        VStack(spacing: 30) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)

            VStack(spacing: 8) {
                Text("Printing Complete!")
                    .font(.title)
                    .fontWeight(.bold)
                Text("Your document is ready.")
                    .foregroundColor(.secondary)
            }

            Button("Print Another Document") {
                selectedFileURL = nil
                documentPageCount = 0
                numberOfCopies = 1
                currentStep = .fileSelection
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
            .controlSize(.large)
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
            self.currentStep = .printingOddPages
        } else {
            self.errorMessage = "Failed to load PDF."
        }
    }

    private func printOddPages() {
        if dryRunEnabled {
            self.currentStep = .printingEvenPages
            return
        }
        guard PrintManager.shared.hasPDF else { return }
        do {
            try PrintManager.shared.printOddPages(copies: numberOfCopies)
             // Transition happens AFTER successful print dialog presentation
             // Note: In a real app we'd want a callback from PrintManager when the print job finishes,
             // but for this utility, progressing immediately after queuing is acceptable.
            self.currentStep = .printingEvenPages
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func printEvenPagesReversed() {
        if dryRunEnabled {
            self.currentStep = .done
            return
        }
        guard PrintManager.shared.hasPDF else { return }
        do {
            try PrintManager.shared.printEvenPagesReversed(copies: numberOfCopies)
            self.currentStep = .done
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
