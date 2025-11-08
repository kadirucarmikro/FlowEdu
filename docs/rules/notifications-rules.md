# Notifications Module Rules

## Module Status: ✅ COMPLETED

## Architecture
- Clean Architecture implementation
- Riverpod state management
- Supabase integration
- Responsive design
- GoRouter navigation

## Key Features
- CRUD operations (Create, Read, Update, Delete)
- Notification types: Automatic, Manual, Interactive
- Interactive responses system
- Target group management
- Response tracking

## Code Patterns

### Notification Card Design
```dart
class NotificationCard extends StatelessWidget {
  // Use direct IconButton actions instead of PopupMenuButton
  // Implement proper overflow handling
  // Use responsive design
  // Handle text truncation properly
}
```

### Responsive Layout
```dart
LayoutBuilder(
  builder: (context, constraints) {
    final isWideScreen = constraints.maxWidth > 600;
    if (isWideScreen) {
      return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: constraints.maxWidth > 1400 ? 4 : 
                         constraints.maxWidth > 1000 ? 3 : 2,
          childAspectRatio: constraints.maxWidth > 1000 ? 1.2 : 1.5,
        ),
      );
    } else {
      return ListView.builder(/* List layout */);
    }
  },
)
```

### Interactive Notifications
```dart
// Handle interactive notification responses
void _handleNotificationResponse(String response) {
  // Process response
  // Update UI
  // Show feedback
}
```

## RLS Policies
- Members can only see notifications targeted to them
- Admins can manage all notifications
- Proper permission checks implemented
- Secure data access patterns

## Best Practices
- Always validate notification data
- Implement proper error handling
- Use responsive design patterns
- Handle interactive responses properly
- Implement proper loading states
- Use secure data access patterns
