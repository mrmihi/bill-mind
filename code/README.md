# billMind - Advanced Bill Management App

A sophisticated bill management application for iPadOS and macOS, built with SwiftUI and leveraging Apple's latest technologies.

## 🚀 Features

### Core Functionality
- **Bill Management**: Create, edit, and track bills with due dates
- **Transaction Tracking**: Monitor spending across different categories
- **Smart Notifications**: Automated reminders for upcoming bills
- **Receipt Scanning**: OCR-powered receipt scanning with Vision Framework
- **Receipt Annotation**: PencilKit integration for marking up receipts

### Advanced Features
- **CloudKit Sync**: Seamless cross-device synchronization
- **AI Analytics**: Spending pattern analysis and predictions
- **Multi-window Support**: Dedicated windows for analytics and scanning (macOS)
- **Export Options**: CSV, PDF, and Excel export capabilities
- **Advanced Categorization**: 10+ bill categories with smart auto-categorization

### Platform-Specific Features

#### iPadOS
- **PencilKit Integration**: Natural receipt annotation with Apple Pencil
- **Touch Gestures**: Intuitive navigation and interaction
- **Keyboard Shortcuts**: Power user efficiency
- **Multi-window Support**: Side-by-side bill comparison

#### macOS
- **Menu Bar Actions**: Quick access to common functions
- **Multi-window Support**: Dedicated windows for different tasks
- **Keyboard Navigation**: Full keyboard accessibility
- **Native macOS UI**: Respects platform conventions

## 🖥️ macOS Catalyst

> _Full desktop class power, same SwiftUI code._

### Key Features
- Native menu-bar shortcuts for quick actions
- Multiple windows: open Analytics, Scanner, and the main list side-by-side
- Drag-and-drop receipts or PDFs straight onto the window for instant OCR
- Keyboard-centric navigation throughout the app

### Screenshots (placeholders)
<!-- Replace the links below with real images -->
| Overview | Analytics |
|----------|-----------|
| ![Catalyst overview](docs/mac_overview_placeholder.png) | ![Catalyst analytics](docs/mac_analytics_placeholder.png) |

## ⌚️ watchOS

> _Bills at a glance, right from your wrist._

### Key Features
- Next-unpaid-bill complication to keep you on schedule
- Lightweight bill list with quick paid/unpaid toggles
- CloudKit sync so status updates reflect instantly across devices
- Works offline and syncs when connectivity returns

### Screenshots (placeholders)
<!-- Replace the links below with real images -->
| Next Bill | Bill List |
|-----------|-----------|
| ![watchOS next](docs/watch_next_placeholder.png) | ![watchOS list](docs/watch_list_placeholder.png) |

## 🛠 Technical Stack

- **SwiftUI**: Modern declarative UI framework
- **SwiftData**: Persistent storage with CloudKit integration
- **CloudKit**: Cross-device synchronization
- **Vision Framework**: Receipt scanning and OCR
- **PencilKit**: Receipt annotation and drawing
- **Charts Framework**: Data visualization
- **Core ML**: Intelligent predictions and categorization

## 📱 Screenshots

### Home Dashboard
- Overview of unpaid bills and total amounts
- Quick action buttons for adding bills and exporting data
- CloudKit sync status indicator
- Upcoming bills preview

### Receipt Scanner
- Camera integration for live scanning
- Photo picker for existing images
- OCR text extraction with Vision Framework
- PencilKit annotation support
- Automatic bill creation from scanned data

### Analytics
- Time-based filtering (week, month, quarter, year)
- Spending trend analysis with interactive charts
- Category breakdown visualization
- AI-powered spending predictions
- Risk assessment for overdue bills

### Settings
- CloudKit sync status monitoring
- Export format preferences
- Notification settings
- Currency and reminder preferences

## 🚀 Getting Started

### Prerequisites
- Xcode 15.0 or later
- iOS 17.0+ / macOS 14.0+
- Apple Developer Account (for CloudKit features)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/billMind.git
   cd billMind
   ```

2. **Open in Xcode**
   ```bash
   open billMind.xcodeproj
   ```

3. **Configure CloudKit**
   - In Xcode, select the project
   - Go to "Signing & Capabilities"
   - Add "iCloud" capability
   - Configure CloudKit container

4. **Build and Run**
   - Select your target device (iPad or Mac)
   - Press Cmd+R to build and run

### Configuration

#### CloudKit Setup
1. Enable iCloud in your device settings
2. Sign in with your Apple ID
3. Grant permission for billMind to access iCloud

#### Camera and Photo Access
1. Grant camera access for receipt scanning
2. Grant photo library access for importing receipts

## 🧪 Testing

The project includes comprehensive unit tests for all core functionality:

```bash
# Run all tests
Cmd+U in Xcode

# Run specific test file
Select test file and press Cmd+U
```

### Test Coverage
- Bill model creation and validation
- Status management (paid/unpaid transitions)
- Overdue calculation logic
- Frequency and next date calculations
- Category and payment method handling
- Receipt and annotation functionality

## 📊 Architecture

### Data Model
```swift
@Model
final class Bill: Identifiable {
    // Core properties
    var id: UUID
    var name: String
    var date: Date
    var amount: Double
    
    // Categorization
    var categoryRaw: Category
    var paymentModeRaw: PaymentMode
    var frequencyRaw: Frequency?
    var statusRaw: Status
    
    // Advanced features
    var notes: String?
    var tags: [String]
    var receiptData: Data?
    var receiptAnnotations: Data?
    var cloudKitRecordID: String?
}
```

### Key Components
- **Models**: Bill and Transaction data models
- **Views**: SwiftUI views for all screens
- **Utils**: Helper classes for notifications, export, etc.
- **Tests**: Comprehensive unit test suite

## 🔧 Development

### Project Structure
```
billMind/
├── Models/
│   ├── Bill.swift
│   ├── Transaction.swift
│   └── ModelContainer.swift
├── Views/
│   ├── ContentView.swift
│   ├── HomeDashboardView.swift
│   ├── AnalyticsView.swift
│   ├── ReceiptScannerView.swift
│   └── SettingsView.swift
├── Utils/
│   ├── CloudKitSyncMonitor.swift
│   ├── NotificationManager.swift
│   └── ExportService.swift
└── Tests/
    └── BillModelTests.swift
```

### Adding New Features
1. Create new SwiftUI views in the `Views/` directory
2. Add data models to the `Models/` directory
3. Implement utility functions in the `Utils/` directory
4. Add corresponding tests in the `Tests/` directory

## 📈 Performance

### Optimizations
- Lazy loading for large datasets
- Efficient SwiftData queries
- Background processing for analytics
- Memory management for image data
- Conditional compilation for platform-specific features

### Memory Management
- Automatic cleanup of receipt images
- Efficient CloudKit sync handling
- Background task management

## 🔒 Security

### Data Protection
- CloudKit encryption for all data
- Secure local storage with SwiftData
- No sensitive data logging
- User-controlled data export

### Privacy
- Camera and photo access only when needed
- Local processing for OCR (no data sent to external servers)
- User control over sync settings

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Apple for providing excellent frameworks and documentation
- SwiftUI community for best practices and examples
- TestFlight users for valuable feedback

## 📞 Support

For support, email support@billmind.app or create an issue in this repository.

## 🔄 Version History

### v1.0.0 (Current)
- Initial release with core bill management
- CloudKit synchronization
- Receipt scanning with Vision Framework
- PencilKit annotation support
- Advanced analytics with Core ML
- Platform-specific optimizations
- Comprehensive testing suite

---

**Built with ❤️ using SwiftUI and Apple's latest technologies** 