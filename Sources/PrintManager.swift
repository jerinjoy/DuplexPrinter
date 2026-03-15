//
//  PrintManager.swift
//  DuplexPrinter
//
//  Created by Jerin Joy & Noel Joy on 2026.
//  Copyright © 2026 Jerin Joy & Noel Joy. All rights reserved.
//

import Foundation
import PDFKit
import AppKit

class PrintManager {
    static let shared = PrintManager()
    
    private var document: PDFDocument?
    
    var hasPDF: Bool { document != nil }
    var pageCount: Int? { document?.pageCount }
    
    func loadPDF(url: URL) -> Bool {
        let isSecurityScoped = url.startAccessingSecurityScopedResource()
        defer {
            if isSecurityScoped {
                url.stopAccessingSecurityScopedResource()
            }
        }
        
        do {
            let data = try Data(contentsOf: url)
            if let pdf = PDFDocument(data: data) {
                self.document = pdf
                return true
            }
        } catch {
            print("Failed to read PDF data: \(error)")
        }
        return false
    }
    
    func printOddPages(copies: Int = 1) throws {
        guard let doc = document else { throw NSError(domain: "PrintManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "No document loaded"]) }
        
        let printDoc = PDFDocument()
        let count = doc.pageCount
        
        // 0-indexed: even indices are physical odd pages (1, 3, 5...)
        for i in 0..<count {
            if i % 2 == 0 {
                if let page = doc.page(at: i) {
                    let pageCopy = page.copy() as! PDFPage
                    printDoc.insert(pageCopy, at: printDoc.pageCount)
                }
            }
        }
        
        printDocument(printDoc, jobName: "Odd Pages", copies: copies)
    }
    
    func printEvenPagesReversed(copies: Int = 1) throws {
        guard let doc = document else { throw NSError(domain: "PrintManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "No document loaded"]) }
        
        let printDoc = PDFDocument()
        let count = doc.pageCount
        
        var evenPageIndices = [Int]() // -1 represents a blank page
        
        // 0-indexed: odd indices are physical even pages (2, 4, 6...)
        for i in 0..<count {
            if i % 2 == 1 {
                evenPageIndices.append(i)
            }
        }
        
        // If count is odd, add a blank page at the end before reversing
        if count % 2 != 0 {
            evenPageIndices.append(-1)
        }
        
        evenPageIndices.reverse()
        
        let defaultBounds = doc.page(at: 0)?.bounds(for: .mediaBox) ?? CGRect(x: 0, y: 0, width: 612, height: 792)
        
        for index in evenPageIndices {
            if index == -1 {
                let emptyImage = NSImage(size: defaultBounds.size)
                emptyImage.lockFocus()
                NSColor.white.set()
                defaultBounds.fill()
                
                // Add a microscopic dot well inside the printable margins (1 inch from corner) 
                // to prevent the print spooler or printer hardware from skipping the blank page.
                let dotRect = CGRect(x: 72, y: 72, width: 1, height: 1)
                NSColor(white: 0.95, alpha: 1.0).setFill()
                dotRect.fill()
                
                emptyImage.unlockFocus()
                
                if let blankPage = PDFPage(image: emptyImage) {
                    printDoc.insert(blankPage, at: printDoc.pageCount)
                }
            } else {
                if let page = doc.page(at: index) {
                    let pageCopy = page.copy() as! PDFPage
                    printDoc.insert(pageCopy, at: printDoc.pageCount)
                }
            }
        }
        
        printDocument(printDoc, jobName: "Even Pages (Reversed)", copies: copies)
    }
    
    private func printDocument(_ pdf: PDFDocument, jobName: String, copies: Int = 1) {
        let printInfo = NSPrintInfo.shared
        printInfo.jobDisposition = .spool
        printInfo.horizontalPagination = .fit
        printInfo.verticalPagination = .fit
        printInfo.dictionary().setObject(copies, forKey: NSPrintInfo.AttributeKey.copies as NSCopying)
        
        // Use PDFDocument's printOperation (available in PDFKit on macOS)
        guard let printOp = pdf.printOperation(for: printInfo, scalingMode: .pageScaleToFit, autoRotate: true) else {
            return
        }
        
        printOp.jobTitle = jobName
        printOp.showsPrintPanel = true
        printOp.showsProgressPanel = true
        
        DispatchQueue.main.async(execute: {
            guard let window = NSApp.windows.first else {
                printOp.run()
                return
            }
            printOp.runModal(for: window, delegate: nil, didRun: nil, contextInfo: nil)
        })
    }
}
