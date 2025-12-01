# Article Creator Flutter App

A complete Flutter application for creating articles with image and video editing capabilities, built with GetX state management.

## Features

- 📝 Rich text editor with HTML support (Flutter Quill)
- 🖼️ Image editing with crop, rotate, flip, zoom, and straighten
- 🎨 Multiple filter presets (Dual, Neon, Film, Vintage, Warm)
- ⚙️ Brightness, contrast, and saturation adjustments
- 🎥 Video thumbnail upload and management
- 📱 Pink-themed UI following Material Design
- 🔄 Reactive state management with GetX
- 📂 Proper file handling with temporary storage

## Requirements

- Flutter SDK 3.0.0 or higher
- Dart 3.0.0 or higher
- Android Studio / Xcode for running on emulators/simulators
- Android SDK 36 (API level 36) for Android builds
- iOS 12.0+ for iOS builds

## Project Structure

```
lib/
├── main.dart
├── routes/
│   ├── app_pages.dart
│   └── app_routes.dart
├── models/
│   ├── article.dart
│   └── media_type.dart
├── services/
│   └── media_service.dart
├── modules/
│   ├── create_article/
│   ├── edit_cover/
│   └── edit_thumbnail/
└── widgets/
    ├── primary_button.dart
    ├── secondary_outline_button.dart
    ├── section_card.dart
    └── segmented_tab.dart
```

## Setup Instructions

1. **Clone or extract the project**

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   
   For Android:
   ```bash
   flutter run
   ```
   
   For iOS:
   ```bash
   flutter run
   ```

4. **Build the app**
   
   For Android APK:
   ```bash
   flutter build apk --release
   ```
   
   For iOS:
   ```bash
   flutter build ios --release
   ```

## Android Configuration

- **compileSdkVersion**: 36
- **targetSdkVersion**: 36
- **minSdkVersion**: 21
- **Gradle**: 8.1.3
- **Kotlin**: 1.9.10

## Key Dependencies

- `get: ^4.6.6` - State management and navigation
- `image_picker: ^1.0.7` - Pick images and videos from gallery
- `video_player: ^2.8.2` - Video playback
- `chewie: ^1.7.5` - Enhanced video player UI
- `flutter_quill: ^9.3.4` - Rich text editor
- `path_provider: ^2.1.2` - Access to file system paths
- `image: ^4.1.7` - Image processing and manipulation
- `extended_image: ^8.2.0` - Advanced image handling

## Usage

### Creating an Article

1. **Add Headline**: Enter your article headline in the text field
2. **Add Cover Media**: 
   - Tap the upload card to select image or video
   - For images: Edit with crop, filters, and adjustments
   - For videos: Add a thumbnail image
3. **Write Content**: Use the rich text editor with formatting options
4. **Post**: Tap the "Post" button to save your article

### Image Editing Features

**Crop Tab:**
- Rotate left/right 90°
- Flip horizontal/vertical
- Aspect ratio selection (Original, Square, 4:1, 3:4, 16:9)
- Zoom slider (1x to 3x)
- Straighten slider (-45° to +45°)

**Filter Tab:**
- None (original)
- Dual (cool blue-violet tones)
- Neon (bright vibrant colors)
- Film (warm vintage look)
- Vintage (aged photo effect)
- Warm (orange-golden tones)

**Adjust Tab:**
- Brightness (-100 to +100)
- Contrast (-100 to +100)
- Saturation (-100 to +100)

### Video Thumbnail

For video articles, you can:
- Upload a custom thumbnail image
- Replace or delete the thumbnail
- Preview the thumbnail with play button overlay

## Design System

### Colors
- Primary: `#FF0A8C` (Bright Pink)
- App Bar: `#FFEEF4` (Soft Pink)
- Background: `#FFFFFF` (White)
- Text: `#222222` (Dark Grey)

### Components
- Rounded corners (12px radius)
- Dashed borders for upload cards
- Circular action buttons with shadows
- Segmented tabs with active states
- Full-width primary buttons (50px height)

## Architecture

The app follows a feature-first GetX architecture:

- **Bindings**: Dependency injection for each module
- **Controllers**: Business logic and state management
- **Pages**: UI views with GetView for type safety
- **Services**: Shared functionality (media picking, file handling)
- **Widgets**: Reusable UI components

## Permissions

The app requires the following permissions:

**Android:**
- `READ_EXTERNAL_STORAGE`
- `WRITE_EXTERNAL_STORAGE`
- `CAMERA`
- `INTERNET`

**iOS:**
- Photo Library Access
- Camera Access
- Microphone Access (for video recording)

## Notes

- All image processing is done efficiently using the `image` package
- Temporary files are stored using `path_provider` for cross-platform compatibility
- Real-time preview updates for filters and adjustments using color matrices
- No artificial loading delays - instant UI feedback

## Troubleshooting

**Gradle Build Issues:**
- Ensure you have JDK 11 or higher installed
- Run `flutter clean` and `flutter pub get`

**Image Picker Not Working:**
- Check permissions in AndroidManifest.xml and Info.plist
- On iOS simulator, you may need to add sample photos

**Build Errors:**
- Delete `build/` folder and rebuild
- Update Flutter: `flutter upgrade`
- Check for conflicting dependencies

## License

This project is provided as-is for demonstration purposes.

## Support

For issues or questions about Flutter:
- Flutter Documentation: https://docs.flutter.dev
- GetX Documentation: https://pub.dev/packages/get
