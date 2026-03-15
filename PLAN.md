# Goal Description
Update the Mac app using SwiftUI to assist with manual duplex printing by implementing a step-by-step UI to print odd pages, prompt the user with an animation to flip and reload the paper, and then print the even pages in reverse order. It will also allow users to select multiple copies of the document.

## Implementation Details
### Xcode Project Overview
- Standard macOS SwiftUI App project in `/Users/joy/workspace/DuplexPrinter`.

### Core Components
#### `ContentView.swift`
- The main UI with a drag-and-drop zone or file selector for PDFs.
- Utilizes a 4-step state machine (`fileSelection` -> `printingOddPages` -> `printingEvenPages` -> `done`).
- Allows users to specify the number of copies they wish to print.
- **`printingEvenPages` step** includes an animation demonstrating how to flip the pages back into the printer.
- Includes "Go Back" and "Restart" functionality to easily correct mistakes or start a new document.

#### `PrintManager.swift`
- Uses `PDFKit` and `NSPrintOperation` to generate temporary PDF documents with the required pages and present the print dialog.
- For documents with an odd number of pages, it appropriately adds a blank page (with a microscopic dot to bypass print spooler bypassing) to the end of the document, ensuring correct ordering when printing the reversed even pages.
- Respects the requested `numberOfCopies` via `NSPrintInfo.shared.copies`.

## Verification Plan
### Automated Tests
- Build the project using `xcodebuild` to ensure successful compilation.
### Manual Verification
- Walk through the visual state changes (`fileSelection` -> `printingOddPages` -> `printingEvenPages` -> `done`).
- Validate reverse transitions using "Go Back" buttons reset the state appropriately.
- Ensure the copies selected in the UI are successfully passed to the `NSPrintPanel`.
- Run the app, select a dummy PDF, and verify the print dialog appears with the correct pages in the correct order for the desired quantity.
