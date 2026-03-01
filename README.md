# Duplex Printer

<div align="center">
  <img src="AppIcon.png" alt="Duplex Printer Icon" width="256" height="256">
</div>
<br>

A simple, native macOS application built with SwiftUI to help you manually print duplex (double-sided) on printers that don't support it natively.

## Features

- **Drag and Drop**: Easily drop a PDF to print.
- **Odd Pages First**: Prints all odd pages sequentially.
- **Smart Even Pages**: After flipping the stack and putting it back in the tray, it prints the even pages in reverse order so they perfectly match the backs of the odd pages without needing to be restacked!
- **Odd Page Count Handling**: Automatically inserts a protective blank page to ensure the final even page isn't printed on the back of the last odd page for documents with an odd number of pages.

## How to Build

Simply open `DuplexPrinter.xcodeproj` in Xcode and click the **Run** button (or press `Cmd + R`).

*(Note: The Xcode project structure was generated using [XcodeGen](https://github.com/yonaskolb/XcodeGen).)*

## Implementation Details
This app was built as a lightweight utility. The core logic handles edge cases such as documents with an odd number of pages (where the system must spool a blank page with a microscopic dot to bypass macOS print spooler skip mechanisms).

- **`ContentView.swift`**: Handles the drag-and-drop interface and state management.
- **`PrintManager.swift`**: Utilizes `PDFKit` to extract and reverse pages, then natively hands them off to `NSPrintOperation` for tight integration with the macOS printing dialog.

## Credits
Created by **Jerin Joy** and **Noel Joy**.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
