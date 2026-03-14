# Theme Configuration Guide

This folder contains all theme-related files for consistent styling across the MTAG Queue Skipper app.

## 📁 Files Overview

### 1. `app_colors.dart`
Contains all color definitions used in the app.

**Pakistani Green Theme Colors:**
- `primaryGreen` - Dark Pakistani Green (#01411C)
- `primaryGreenLight` - Medium Green (#0C6E3A)
- `primaryGreenLighter` - Light Green (#14A44D)

**Usage Example:**
```dart
Container(
  color: AppColors.primaryGreen,
  child: Text(
    'MTAG',
    style: TextStyle(color: AppColors.white),
  ),
)
```

### 2. `app_theme.dart`
Main theme configuration that uses colors from `app_colors.dart`.

**What it defines:**
- Button styles (Elevated, Text, Outlined)
- Input field styles
- Card styles
- AppBar styles
- Text styles (headings, body, labels)
- Icon styles

**Already applied in `main.dart`** - No need to do anything!

### 3. `app_constants.dart`
Contains spacing, sizing, and other constant values.

**Usage Example:**
```dart
Padding(
  padding: EdgeInsets.all(AppConstants.spacingM), // 16.0
  child: Text('Hello'),
)

BorderRadius.circular(AppConstants.radiusM) // 8.0
```

## 🎨 How to Use in Your Screens

### Using Theme Colors
```dart
// Access theme colors
final primaryColor = Theme.of(context).colorScheme.primary;

// Or use directly from AppColors
Container(color: AppColors.primaryGreen)
```

### Using Text Styles
```dart
Text(
  'Heading',
  style: Theme.of(context).textTheme.titleLarge,
)

Text(
  'Body text',
  style: Theme.of(context).textTheme.bodyMedium,
)
```

### Using Buttons (Automatically Styled!)
```dart
// Elevated Button - Already green with white text
ElevatedButton(
  onPressed: () {},
  child: Text('Login'),
)

// Text Button - Already green text
TextButton(
  onPressed: () {},
  child: Text('Forgot Password?'),
)

// Outlined Button - Already green border
OutlinedButton(
  onPressed: () {},
  child: Text('Cancel'),
)
```

### Using Input Fields (Automatically Styled!)
```dart
TextField(
  decoration: InputDecoration(
    labelText: 'Email',
    hintText: 'Enter your email',
  ),
)
// Already has green focus border!
```

### Using Spacing
```dart
SizedBox(height: AppConstants.spacingM) // 16px gap

Padding(
  padding: EdgeInsets.all(AppConstants.spacingL), // 24px padding
  child: YourWidget(),
)
```

## ✅ Benefits

1. **Consistency** - All screens use the same colors and styles
2. **Easy Updates** - Change color once, updates everywhere
3. **Clean Code** - No hardcoded colors in screens
4. **Professional Look** - Cohesive Pakistani green theme

## 🚀 Next Steps

Now that theme is set up:
1. ✅ Theme is ready
2. ➡️ Create reusable widgets (custom buttons, text fields)
3. ➡️ Build screen UIs using these theme colors
4. ➡️ Add functionality later

**Remember:** Don't hardcode colors in your screens! Always use `AppColors` or `Theme.of(context)`.
