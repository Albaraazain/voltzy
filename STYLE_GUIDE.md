# Voltz App Style Guide

## 🎯 Design Philosophy

### Core Principles
- **Modern Minimalism**: Clean, uncluttered layouts with purposeful use of white space
- **Breathing Room**: Generous spacing between elements to create visual hierarchy and improve readability
- **Soft & Approachable**: Pastel color palette and rounded corners for a friendly, approachable feel
- **Purposeful Motion**: Subtle animations that enhance usability without being distracting
- **Content First**: Design that emphasizes content and functionality over decorative elements

### Visual Language
- **White Space**: Abundant use of negative space (minimum 24px padding) to create a light, airy feel
- **Soft Shadows**: Subtle shadows (when used) to create depth without heaviness
- **Rounded Corners**: Consistent use of rounded corners (20-32px) for a modern, friendly appearance
- **Pastel Palette**: Light, soft colors for backgrounds (shade50) with more saturated accents
- **Visual Hierarchy**: Clear content structure through size, weight, and spacing
- **Consistency**: Repeating patterns and components for a cohesive experience

### Page Templates

#### Content-Heavy Pages
- White backgrounds with 24px minimum padding
- Clear section breaks with 32px spacing
- Card-based layout for content grouping
- Maximum content width of 800px on larger screens
- Progressive disclosure for complex information

#### List Views
- 16px spacing between list items
- Subtle dividers or cards to separate items
- Left-aligned content with consistent indentation
- Clear touch targets (minimum 44px height)
- Pull-to-refresh when applicable

#### Detail Pages
- Hero section with large imagery when relevant
- Generous padding around content sections
- Progressive loading for long-form content
- Floating action buttons for primary actions
- Bottom sheets for additional options

#### Forms & Input
- Single column layout
- 24px spacing between form groups
- Clear error states with inline validation
- Floating labels or clear placeholders
- Full-width inputs on mobile

### Content Presentation

#### Images & Media
- Rounded corners matching container style
- Aspect ratio maintenance
- Lazy loading with placeholder
- Maximum width of container
- Optional subtle scaling on interaction

#### Data Visualization
- Minimal, clean charts and graphs
- Pastel color palette for data points
- Clear labels and legends
- Responsive scaling
- Interactive elements clearly indicated

#### Loading States
- Subtle skeleton screens
- Brand-colored progress indicators
- Maintaining layout structure while loading
- Smooth transitions when content loads

### Interaction Patterns

#### Gestures
- Swipe actions where intuitive
- Pull to refresh for content updates
- Smooth scroll behavior
- Clear scroll boundaries
- Haptic feedback for important actions

#### State Changes
- Smooth transitions between states
- Clear loading indicators
- Success/error states with appropriate colors
- Maintaining context during updates
- Undo options for destructive actions

### Brand Expression
- **Personality**: Professional yet approachable
- **Voice**: Clear, confident, helpful
- **Imagery**: Clean, high-quality, purposeful
- **Motion**: Smooth, intentional, enhancing
- **Innovation**: Modern without being trendy

## 🎨 Color Palette

### Primary Colors
- **Amber Primary**: `Colors.amber`
  - Main: `Colors.amber.shade400` (Menu background)
  - Light: `Colors.amber.shade100` (Selected chips)
  - Dark: `Colors.amber.shade700` (Selected text)

### Secondary Colors
- **Service Categories**:
  - Electrical: `Colors.pink` (Base: shade500, Background: shade50, Icon: shade200)
  - Plumbing: `Colors.amber` (Base: shade500, Background: shade50, Icon: shade400)
  - Cleaning: `Colors.green` (Base: shade500, Background: shade50, Icon: shade400)
  - Repair: `Colors.blue` (Base: shade500, Background: shade50, Icon: shade200)

### Neutral Colors
- **Background**: `Colors.white`
- **Text**:
  - Primary: `Colors.grey.shade800`
  - Secondary: `Colors.grey.shade400`
- **Inactive Elements**: `Colors.grey.shade100`
- **Overlay**: `Colors.black.withOpacity(0.3)`

## 📏 Layout & Spacing

### Page Layout
- **Page Padding**: 24px all sides
- **Vertical Spacing**: 
  - Between major sections: 32px
  - Between related elements: 16px
  - Between tight elements: 6px

### Grid System
- **Service Grid**:
  - Columns: 2
  - Gap: 16px
  - Aspect Ratio: 0.85

### Border Radius
- **Large Elements** (Cards, Menu): 32px
- **Medium Elements** (Chips): 20px
- **Small Elements** (Menu Lines): 2px

## 📝 Typography

### Headings
- **Large Title** (Menu):
  ```dart
  TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  )
  ```

- **Page Title**:
  ```dart
  TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  )
  ```

### Body Text
- **Menu Items**:
  ```dart
  TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  )
  ```

- **Card Titles**:
  ```dart
  TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.2,
  )
  ```

- **Chips**:
  ```dart
  TextStyle(
    fontSize: 14,
    color: isSelected ? Colors.amber.shade700 : Colors.grey.shade400,
  )
  ```

## 🎭 Components

### Menu Button (Hamburger)
- Width: 24px
- Line Height: 2px
- Line Spacing: 6px
- Padding: 12px
- Color: `Colors.grey.shade800`
- Touch Target: Minimum 44x44px (with padding)

### Filter Chips
- Horizontal Padding: 12px
- Vertical Padding: 4px
- Border Radius: 20px
- States:
  - Selected: 
    - Background: `Colors.amber.shade100`
    - Text: `Colors.amber.shade700`
  - Unselected:
    - Background: `Colors.grey.shade100`
    - Text: `Colors.grey.shade400`

### Service Cards
- Padding: 16px
- Border Radius: 32px
- Icon Size: 96x96
- Background: `color.shade50`
- Layout:
  - Title at top
  - Icon centered in remaining space

### Bottom Navigation
- Icon Size: Default
- Active Color: `Colors.amber.shade500`
- Inactive Color: `Colors.grey.shade400`
- Indicator:
  - Size: 4x4px
  - Color: `Colors.amber.shade500`
  - Shape: Circle

### Sidebar Menu
- Width: 75% of screen width
- Background: `Colors.amber.shade400`
- Border Radius: 32px (right side)
- Padding:
  - Header: 24px horizontal, 32px top, 48px bottom
  - Items: 24px horizontal
- Animation:
  - Duration: 400ms
  - Curve: `Curves.easeOutCubic`
  - Item Stagger: 0.1s delay between items

## 🎬 Animations

### Menu Transitions
```dart
// Main Menu Animation
Duration: 400ms
Curve: Curves.easeOutCubic
Properties: slide + fade

// Menu Items Stagger
Interval: 0.4 + (index * 0.1)
Curve: Curves.easeOutCubic
Properties: slide + fade
```

### Interactive Elements
- Chips: Default Material ripple
- Menu Button: Default Material ink response
- Menu Items: Default Material ink response

## 📱 Responsive Behavior

### Breakpoints
- Currently optimized for mobile
- Menu width: 75% of screen width
- Grid maintains 2 columns with flexible card sizes

## 🌈 Icons

### Navigation Icons
- Home: `Icons.home`
- Favorites: `Icons.favorite_border`
- History: `Icons.access_time`
- Profile: Circle placeholder

### Menu Icons
- Store: `Icons.store`
- Premium: `Icons.star`
- Settings: `Icons.settings`
- Support: `Icons.help`
- Logout: `Icons.logout`
- Close: `Icons.close`

## 🎯 Touch Targets
- Minimum touch target size: 44x44px
- Adequate spacing between interactive elements
- Clear visual feedback on interaction

## 🔒 Accessibility
- High contrast text colors
- Adequate text sizes (minimum 14sp)
- Clear visual hierarchy
- Sufficient touch targets
- Semantic labels (to be added)

---

This style guide should be followed for all new features and components to maintain consistency throughout the app. Update this document as new design decisions are made. 