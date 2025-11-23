# Dartotsu Extension Bridge

A Flutter plugin that provides a unified interface for managing multiple extension systems (Aniyomi, Mangayomi, and CloudStream) for streaming and reading content across various media types.

## Overview

The Dartotsu Extension Bridge enables Flutter applications to discover, install, update, and manage extensions from four different extension ecosystems:

- **Aniyomi**: Anime and manga extensions (APK-based)
- **Mangayomi**: Anime, manga, and novel extensions (APK-based)
- **CloudStream**: Video streaming extensions supporting 9 content types (APK-based)
- **LnReader**: Light novel and web novel extensions (JavaScript-based)

## Features

### Multi-Extension System Support

- Seamlessly switch between Aniyomi, Mangayomi, and CloudStream extension systems
- Unified API for extension management across all systems
- Persistent extension type selection

### Content Type Support

The bridge supports 9 different content types:

- Anime
- Manga
- Novel
- Movie
- TV Show
- Cartoon
- Documentary
- Livestream
- NSFW

### Extension Management

- **Discovery**: Fetch available extensions from remote repositories
- **Installation**: Download and install extension APKs
- **Updates**: Automatic update detection with version comparison
- **Uninstallation**: Remove extensions with cleanup
- **Repository Management**: Configure multiple extension repositories per content type

### LnReader Extension Bridge (Latest Addition)

The LnReader Extension Bridge is the newest addition, providing comprehensive support for JavaScript-based light novel and web novel extensions. Unlike the APK-based extension systems (Aniyomi, CloudStream, Mangayomi), LnReader plugins are distributed as compiled JavaScript code that executes in a sandboxed QuickJS runtime environment.

#### Key Features

- JavaScript-based plugin system (no APK installation required)
- Access to 100+ novel sources across 17 languages
- Sandboxed QuickJS runtime for secure plugin execution
- Code-based distribution via JSON repositories
- Support for popular novel sites (Royal Road, Wuxiaworld, NovelUpdates, etc.)
- Cross-platform support (works on all platforms, not just Android)
- Lazy runtime initialization for optimal memory usage
- Built-in JavaScript libraries (cheerio, htmlparser2, dayjs)

#### Architecture

```
Flutter Application
        ↓
ExtensionManager (Coordinator)
        ↓
┌───────────────┬──────────────────┬──────────────┬──────────────┐
│   Aniyomi     │   CloudStream    │  Mangayomi   │  LnReader    │
│   (APK)       │     (APK)        │    (APK)     │    (JS)      │
└───────┬───────┴────────┬─────────┴──────┬───────┴──────┬───────┘
        ↓                ↓                 ↓              ↓
    Platform Channel                              QuickJS Runtime
        ↓                                              ↓
    Native Android                            JavaScript Plugins
```

#### Implementation Details

**Dart Layer** (`lib/Lnreader/`):

- `LnReaderExtensions.dart`: Main extension management class
- `LnReaderSourceMethods.dart`: Content source operations
- `service.dart`: QuickJS runtime and plugin execution
- `js_*.dart`: JavaScript polyfills and library implementations

**JavaScript Runtime**:

- QuickJS engine with 4MB stack size
- Sandboxed execution environment
- Promise support with async/await
- Custom `require()` function for library loading
- HTTP client integration via `fetchApi`

**Plugin Format**:

Plugins are distributed via `plugins.min.json` files:

```json
{
  "plugins": [
    {
      "id": "royalroad",
      "name": "Royal Road",
      "version": "2.2.3",
      "lang": "en",
      "icon": "https://example.com/icon.png",
      "site": "https://www.royalroad.com/",
      "code": "module={},exports=Function(\"return this\")()...[compiled JS]"
    }
  ]
}
```

**Data Models** (`lib/Lnreader/m_plugin.dart`):

- `NovelItem`: Basic novel information (name, path, cover)
- `ChapterItem`: Chapter metadata (name, path, releaseTime)
- `SourceNovel`: Complete novel details (genres, summary, author, status, chapters)

#### Key Differences from APK-Based Extensions

| Feature              | APK-Based (Aniyomi/CloudStream/Mangayomi) | JavaScript-Based (LnReader)                |
| -------------------- | ----------------------------------------- | ------------------------------------------ |
| **Distribution**     | APK files requiring installation          | JavaScript code in JSON files              |
| **Platform Support** | Android only                              | All platforms (Android, iOS, Web, Desktop) |
| **Installation**     | Requires Android package manager          | Direct code storage in database            |
| **Security**         | Android sandbox                           | QuickJS runtime sandbox                    |
| **Updates**          | APK replacement                           | Code replacement                           |
| **Size**             | Larger (APK overhead)                     | Smaller (just code)                        |
| **Execution**        | Native Android code                       | JavaScript interpretation                  |
| **Development**      | Kotlin/Java                               | JavaScript/TypeScript                      |

#### JavaScript Runtime Features

**Available Libraries**:

- **cheerio**: jQuery-like HTML parsing and manipulation
- **htmlparser2**: Fast HTML parser
- **dayjs**: Date/time manipulation
- **fetchApi**: HTTP client for network requests

**Polyfills**:

- Promise support with async/await
- JSON stringify/parse
- Standard JavaScript features

**Security**:

- 4MB stack limit prevents stack overflow attacks
- No direct file system access
- Controlled network access via fetchApi
- No native code execution
- Per-plugin runtime isolation

### CloudStream Extension Bridge

The CloudStream Extension Bridge provides comprehensive support for CloudStream video streaming extensions.

#### Key Features

- Support for all 9 content types
- APK-based extension distribution
- Automatic update detection
- Repository persistence via Isar database
- Platform channel integration with native Android code
- Concurrent extension loading for improved performance
- Comprehensive error handling and logging

#### Architecture

```
Flutter Application
        ↓
ExtensionManager (Coordinator)
        ↓
┌───────────────┬──────────────────┬──────────────┐
│   Aniyomi     │   CloudStream    │  Mangayomi   │
│   Bridge      │     Bridge       │    Bridge    │
└───────┬───────┴────────┬─────────┴──────┬───────┘
        ↓                ↓                 ↓
    Platform Channel Layer
        ↓                ↓                 ↓
    Native Android Implementation
```

#### Implementation Details

**Dart Layer** (`lib/CloudStream/`):

- `CloudStreamExtensions.dart`: Main extension management class
- `CloudStreamSourceMethods.dart`: Content source operations

**Native Layer** (`android/src/main/kotlin/`):

- `CloudStreamBridge.kt`: Platform channel handler for querying installed CloudStream APKs

**Data Models** (`lib/Models/`):

- `Source.dart`: Extension metadata model
- `ItemType`: Content type enumeration

**Settings** (`lib/Settings/`):

- `Settings.dart`: Isar database schema for repository persistence

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  dartotsu_extension_bridge:
    git:
      url: https://github.com/wuxnz/DartotsuExtensionBridge.git
```

To install a specific version or branch:

```yaml
dependencies:
  dartotsu_extension_bridge:
    git:
      url: https://github.com/wuxnz/DartotsuExtensionBridge.git
      ref: main # or specify a tag/commit hash
```

## Usage

### Initialize Extension Manager

```dart
import 'package:dartotsu_extension_bridge/dartotsu_extension_bridge.dart';

// Get the extension manager
final extensionManager = Get.find<ExtensionManager>();

// Switch to CloudStream
await extensionManager.setCurrentManager(ExtensionType.cloudstream);

// Switch to LnReader
await extensionManager.setCurrentManager(ExtensionType.lnreader);
```

### Fetch Available Extensions

```dart
final cloudstream = Get.find<CloudStreamExtensions>(tag: 'CloudStreamExtensions');

// Fetch anime extensions from repositories
final repos = ['https://example.com/cloudstream-extensions.json'];
await cloudstream.fetchAvailableAnimeExtensions(repos);

// Access available extensions
final available = cloudstream.availableAnimeExtensions.value;
```

### Install an Extension

```dart
final source = cloudstream.availableAnimeExtensions.value.first;
await cloudstream.installSource(source);
```

### Check for Updates

```dart
await cloudstream.checkForUpdates(ItemType.anime);

// Find extensions with updates
final updatable = cloudstream.installedAnimeExtensions.value
    .where((s) => s.hasUpdate == true);
```

### Update an Extension

```dart
final source = updatable.first;
await cloudstream.updateSource(source);
```

### Uninstall an Extension

```dart
await cloudstream.uninstallSource(source);
```

### LnReader Usage Examples

#### Fetch Available Novel Plugins

```dart
final lnreader = Get.find<LnReaderExtensions>(tag: 'LnReaderExtensions');

// Fetch plugins from repository
final repos = ['https://raw.githubusercontent.com/LNReader/lnreader-plugins/plugins/v3.0.0/plugins.min.json'];
await lnreader.fetchAvailableNovelExtensions(repos);

// Access available plugins
final available = lnreader.availableNovelExtensions.value;
```

#### Install a Novel Plugin

```dart
final plugin = lnreader.availableNovelExtensions.value.first;
await lnreader.installSource(plugin);

// Plugin is now available in installed list
final installed = lnreader.installedNovelExtensions.value;
```

#### Browse Popular Novels

```dart
// Get source methods for the installed plugin
final sourceMethods = plugin.currentSourceMethods();

// Fetch popular novels (page 1)
final popularNovels = await sourceMethods.getPopular(1);

// Access novel items
for (final novel in popularNovels.list) {
  print('${novel.name}: ${novel.link}');
}
```

#### Search for Novels

```dart
// Search for novels by query
final searchResults = await sourceMethods.search('cultivation', 1, []);

// Access search results
for (final novel in searchResults.list) {
  print('Found: ${novel.name}');
}
```

#### Get Novel Details

```dart
// Get detailed information about a novel
final novelDetails = await sourceMethods.getDetail(novel.link);

// Access novel metadata
print('Title: ${novelDetails.name}');
print('Author: ${novelDetails.author}');
print('Status: ${novelDetails.status}');
print('Summary: ${novelDetails.description}');
print('Genres: ${novelDetails.genre?.join(', ')}');

// Access chapters
for (final chapter in novelDetails.chapters ?? []) {
  print('Chapter ${chapter.name}: ${chapter.url}');
}
```

#### Read Chapter Content

```dart
// Get chapter HTML content
final chapterContent = await sourceMethods.getHtmlContent(
  chapter.name,
  chapter.url,
);

// Display content (HTML string)
print(chapterContent);
```

#### Check for Plugin Updates

```dart
await lnreader.checkForUpdates(ItemType.novel);

// Find plugins with updates
final updatable = lnreader.installedNovelExtensions.value
    .where((s) => s.hasUpdate == true);
```

#### Update a Plugin

```dart
final plugin = updatable.first;
await lnreader.updateSource(plugin);
```

#### Uninstall a Plugin

```dart
await lnreader.uninstallSource(plugin);
```

## Testing

The project includes comprehensive test coverage:

### Property-Based Tests

**CloudStream**: 18 properties tested with 100 iterations each, verifying:

- Initialization idempotence
- Repository persistence
- Extension type consistency
- Platform failure handling
- Installation/uninstallation workflows
- Update detection
- Content type routing

**LnReader**: 26 properties tested with 100 iterations each, verifying:

- Extension type persistence and filtering
- Content type support invariants
- Plugin metadata parsing completeness
- Installation/update/uninstallation workflows
- JavaScript runtime initialization
- Library availability
- Version comparison correctness
- Novel/chapter content structure
- Error handling and state preservation

### Integration Tests

**CloudStream**: 5 complete end-to-end workflows:

- Installation flow (fetch → install → verify)
- Update flow (install → detect → update → verify)
- Uninstallation flow (install → uninstall → verify)
- Multi-type management (all 9 content types)

**LnReader**: 6 complete end-to-end workflows:

- Installation workflow (fetch → install → verify)
- Update workflow (install old → detect → update → verify)
- Uninstallation workflow (install → uninstall → verify)
- Browsing workflow (install → fetch popular → verify)
- Search workflow (install → search → verify)
- Reading workflow (install → get details → get content → verify)

### Edge Case Tests

9 edge cases covering:

- Empty database initialization
- Invalid repository URLs
- Malformed data handling
- Concurrent operations
- Platform channel failures
- JavaScript runtime errors
- Plugin parsing failures

Run tests with:

```bash
flutter test
```

## Platform Support

### APK-Based Extensions (Aniyomi, CloudStream, Mangayomi)

- **Android**: Full support (API 21+)
- **iOS**: Not supported (requires APK installation)
- **Web**: Not supported
- **Desktop**: Not supported

### JavaScript-Based Extensions (LnReader)

- **Android**: Full support (API 21+)
- **iOS**: Full support (iOS 11+)
- **Web**: Full support
- **Desktop**: Full support (Windows, macOS, Linux)

LnReader works on all platforms because it doesn't require native APK handling - plugins are JavaScript code executed in a QuickJS runtime.

## Requirements

### General

- Flutter SDK: >=3.0.0
- Dart SDK: >=3.0.0

### APK-Based Extensions (Aniyomi, CloudStream, Mangayomi)

- Android: minSdkVersion 21
- Permissions: `INSTALL_PACKAGES`, `REQUEST_INSTALL_PACKAGES`

### JavaScript-Based Extensions (LnReader)

- QuickJS runtime (included via flutter_qjs package)
- No special permissions required
- Works on all platforms

## Architecture

### Extension Abstract Class

All extension bridges extend the `Extension` abstract class, providing:

- Reactive lists for installed/available extensions
- Content type support flags
- Version comparison utilities
- Standardized method signatures

### Platform Channels

Native Android integration via MethodChannel:

- Query installed extension APKs
- Parse extension metadata
- Handle package installation/uninstallation

### Database Persistence

Isar database for storing:

- Repository URLs per content type
- Extension type selection
- Extension metadata

## Recent Changes

### LnReader Extension Bridge Implementation (Latest)

- Added complete LnReader extension support with JavaScript-based plugins
- Implemented QuickJS runtime with 4MB stack for secure plugin execution
- Added support for 100+ novel sources across 17 languages
- Created comprehensive JavaScript polyfills and library implementations
- Implemented lazy runtime initialization for optimal memory usage
- Added 26 property-based tests with 100 iterations each
- Created 6 integration tests for complete workflows
- Enabled cross-platform support (Android, iOS, Web, Desktop)
- Implemented code-based distribution via JSON repositories
- Added support for cheerio, htmlparser2, and dayjs libraries

### CloudStream Extension Bridge Implementation

- Added complete CloudStream extension support
- Implemented all 9 content types (anime, manga, novel, movie, TV show, cartoon, documentary, livestream, NSFW)
- Created native Android bridge for APK management
- Added comprehensive property-based testing
- Implemented repository persistence
- Added automatic update detection
- Created integration tests for complete workflows

### Code Quality Improvements

- Fixed non-exhaustive switch statements across all extension bridges
- Added proper error handling for new content types
- Updated UI components to support all content types
- Improved test coverage to 58+ passing tests

## Contributing

When adding new features:

1. Update the spec documents in `.kiro/specs/`
2. Follow the existing architectural patterns
3. Add property-based tests for new functionality
4. Update integration tests for end-to-end workflows
5. Ensure all switch statements handle all ItemType values

## License

See LICENSE file for details.

## Documentation

For detailed design documentation, see:

### LnReader Extension Bridge

- `.kiro/specs/lnreader-extension-bridge/requirements.md` - Complete requirements specification
- `.kiro/specs/lnreader-extension-bridge/design.md` - Architecture and design decisions
- `.kiro/specs/lnreader-extension-bridge/tasks.md` - Implementation task list

### CloudStream Extension Bridge

- `.kiro/specs/cloudstream-extension-bridge/requirements.md`
- `.kiro/specs/cloudstream-extension-bridge/design.md`
- `.kiro/specs/cloudstream-extension-bridge/tasks.md`

## Plugin Development

### LnReader Plugin Structure

LnReader plugins must implement the `Plugin.PluginBase` interface:

```javascript
// Plugin structure
const plugin = {
  id: "example-source",
  name: "Example Source",
  version: "1.0.0",
  icon: "https://example.com/icon.png",
  site: "https://example.com",

  // Fetch popular novels
  popularNovels: async (page) => {
    // Return array of NovelItem objects
    return [
      {
        name: "Novel Title",
        path: "/novel/path",
        cover: "https://example.com/cover.jpg",
      },
    ];
  },

  // Search for novels
  searchNovels: async (searchTerm, page) => {
    // Return array of NovelItem objects
    return [];
  },

  // Get novel details
  parseNovel: async (novelPath) => {
    // Return SourceNovel object
    return {
      name: "Novel Title",
      path: novelPath,
      cover: "https://example.com/cover.jpg",
      summary: "Novel description",
      author: "Author Name",
      status: "Ongoing",
      genres: ["Fantasy", "Adventure"],
      chapters: [
        {
          name: "Chapter 1",
          path: "/chapter/1",
          releaseTime: "2024-01-01",
        },
      ],
    };
  },

  // Get chapter content
  parseChapter: async (chapterPath) => {
    // Return HTML string
    return "<p>Chapter content...</p>";
  },
};

// Export plugin
exports.default = plugin;
```

### Available JavaScript Libraries

Plugins have access to the following libraries via `require()`:

```javascript
// HTML parsing with cheerio
const cheerio = require("cheerio");
const $ = cheerio.load(html);
const title = $("h1").text();

// HTML parsing with htmlparser2
const htmlparser2 = require("htmlparser2");
const parser = new htmlparser2.Parser({
  onopentag(name, attrs) {
    // Handle tags
  },
});

// Date manipulation with dayjs
const dayjs = require("dayjs");
const date = dayjs("2024-01-01").format("YYYY-MM-DD");

// HTTP requests with fetchApi
const response = await fetch("https://example.com/api");
const data = await response.json();
```

### Plugin Repository Format

Create a `plugins.min.json` file to distribute your plugins:

```json
{
  "plugins": [
    {
      "id": "unique-plugin-id",
      "name": "Plugin Display Name",
      "version": "1.0.0",
      "lang": "en",
      "icon": "https://example.com/icon.png",
      "site": "https://source-website.com",
      "code": "module={},exports=Function(\"return this\")();[compiled JavaScript code]"
    }
  ]
}
```

The `code` field should contain the compiled JavaScript code as a single string. Use a bundler like webpack or rollup to compile your plugin code.

### JavaScript Runtime Limitations

The QuickJS runtime has some limitations:

- **Stack Size**: 4MB limit (prevents infinite recursion)
- **No File System**: Cannot access local files directly
- **Controlled Network**: HTTP requests go through fetchApi
- **No Native Code**: Cannot call native platform APIs
- **ES6 Support**: Most ES6 features supported, but not all ES2020+ features

### Security Considerations

- Plugins run in a sandboxed QuickJS environment
- No direct access to file system or native APIs
- Network requests are controlled and monitored
- Each plugin gets its own isolated runtime
- Stack overflow protection via 4MB limit
