# Goal Description
Create a Mac app using SwiftUI to assist with manual duplex printing. The app will extract and print odd pages, prompt the user to flip and reload the paper, and then print the even pages in reverse order.

## Implementation Details
### Xcode Project Overview
- Standard macOS SwiftUI App project in `/Users/joy/workspace/DuplexPrinter`.

### Core Components
#### `ContentView.swift`
- The main UI with a drag-and-drop zone or file selector for PDFs.
- Simple step-by-step state management (Select -> Print Odds -> Wait -> Print Evens).
- Uses `fileImporter` for file selection as well as a drop zone.

#### `PrintManager.swift`
- Uses `PDFKit` and `NSPrintOperation` to generate temporary PDF documents with the required pages and present the print dialog.
- For documents with an odd number of pages, it appropriately adds a blank page (with a microscopic dot to bypass print spooler bypassing) to the end of the document, ensuring correct ordering when printing the reversed even pages.

## Verification Plan
### Automated Tests
- Build the project using `xcodebuild` to ensure successful compilation.
### Manual Verification
- Provide instructions to run the app, select a dummy PDF, and verify the print dialog appears with the correct pages in the correct order.
