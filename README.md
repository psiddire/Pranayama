# Pranayama App for Garmin Vivoactive 4

A 10-minute pranayama (breathing) session app designed for Garmin Vivoactive 4 smartwatches. Features animated breathing exercises for four traditional pranayama techniques.

## Features

### 10-Minute Session Structure
1. **Bhastrika (Bellows Breath)**
   - Rapid forceful breathing

2. **Kapalabhati (Skull Shining)**
   - Forceful exhale

3. **Nadi Shodhana (Alternate Nostril)**
   - Alternating nostril breathing

4. **Bhramari (Humming Bee)**
   - Humming exhale with hexagonal vibration patterns

## Workflow

### Prerequisites
1. **Garmin Connect IQ SDK** 8.2.1 or later
2. **Visual Studio Code** with Monkey C extension
3. **Garmin Vivoactive 4** or **Vivoactive 4S**

### Build
1. **Open Project in VSCode**:
   ```
   File > Open Folder > Select PranayamaApp folder
   ```
2. **Select Target Device**:
   - Press `Cmd + Shift + P`
   - Type "Monkey C: Set Target Device"
   - Select "vivoactive4"
3. **Build App**:
   - Press `Cmd + Shift + P`
   - Type "Monkey C: Build for Device"
   - Or use shortcut: `Cmd + F5`
4. **Output**:
   - Built app will be in `bin/` folder
   - File: `PranayamaApp.prg`

### File Structure After Build
```
PranayamaApp/
├── source/           # Monkey C source files
├── resources/        # App resources
├── bin/             # Built output (.prg file)
├── manifest.xml     # App configuration
├── monkey.jungle    # Build configuration
└── developer_key.*  # Signing keys
```

### CIQ Simulator
1. **Open VS Code** with PranayamaApp project
2. **Press**: `Cmd + Shift + P`
3. **Type**: "Monkey C: Build Current Project"
4. **Select**: Run > Run Without Debugging
5. **Wait** for simulator to fully load

If the app is correctly configured then the simulator will load correctly. In case of issues you will see the black screen of death. Resolve those issues in that case.

### Development Setup
```bash
# Install Connect IQ SDK via SDK Manager
# Configure VS Code with Monkey C extension
# Set target device to vivoactive4
```

## App Structure

### Core Files
- `PranayamaApp.mc` - Main application entry point
- `PranayamaMainView.mc` - Primary session view with animations
- `PranayamaMainDelegate.mc` - Input handling and navigation
- `PranayamaInstructionsView.mc` - Technique instruction pages
- `PranayamaSettingsView.mc` - App configuration settings

### Resources
- `manifest.xml` - App configuration and permissions
- `strings.xml` - Text localization
- `layout.xml` - UI layout definitions
- `menu.xml` - Menu structure
- `drawables.xml` - Icon and image resources

## Technical Specifications

- **Target Device**: Garmin Vivoactive 4/4S (260x260 pixel display)
- **Memory Usage**: Optimized for Connect IQ memory constraints
- **Battery Impact**: Minimal - efficient rendering and timers
- **SDK Version**: Connect IQ 8.2.1+ (System 8 compatible)
- **Language**: Monkey C

## Future Enhancements

- **Additional Techniques**: Ujjayi, Anulom Vilom, Bhastrika variations
- **Custom Sessions**: User-defined technique combinations
- **Progress Tracking**: Historical session data and statistics
- **Meditation Integration**: Silent meditation periods between techniques
- **Audio Cues**: Optional breathing sound guidance

## License

This project is created for educational and wellness purposes. Traditional pranayama techniques are ancient practices from the yoga tradition.

---

**Created for Garmin Vivoactive 4 | Connect IQ Platform**