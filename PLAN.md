# Goal Description
Create a Mac app using SwiftUI to assist with manual duplex printing. The app will extract and print odd pages, prompt the user to flip and reload the paper, and then print the even pages in reverse order.

## User Review Required
> [!IMPORTANT]
> Please review my clarifying questions in the chat regarding how documents with an odd number of pages should be handled.

## Proposed Changes
### Xcode Project Setup
- Set up a standard macOS SwiftUI App project in `/Users/joy/workspace/DuplexPrinter`.

### Core Components
#### [NEW] `ContentView.swift`
- The main UI with a drag-and-drop zone or file selector for PDFs.
- Simple step-by-step state management (Select -> Print Odds -> Wait -> Print Evens).

#### [NEW] `PrintManager.swift`
- Will use `PDFKit` and `NSPrintOperation` to generate temporary PDF documents with the required pages and present the print dialog.

## Verification Plan
### Automated Tests
- Build the project using `xcodebuild` to ensure successful compilation.
### Manual Verification
- Provide instructions to run the app, select a dummy PDF, and verify the print dialog appears with the correct pages in the correct order.
