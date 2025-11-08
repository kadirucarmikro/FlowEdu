# Events Module Rules

## Module Status: ✅ COMPLETED

## Architecture
- Clean Architecture implementation
- Riverpod state management
- Supabase integration
- Responsive design
- GoRouter navigation

## Key Features
- CRUD operations (Create, Read, Update, Delete)
- Event types: Normal, Interactive, Poll
- Event responses system
- Image support
- Date/time management

## Code Patterns

### Event Card Design
```dart
class EventCard extends StatelessWidget {
  // Use direct IconButton actions instead of PopupMenuButton
  // Implement proper overflow handling with maxLines and TextOverflow.ellipsis
  // Use responsive design with proper constraints
  // Handle text overflow gracefully
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
          childAspectRatio: constraints.maxWidth > 1000 ? 1.0 : 1.2,
        ),
      );
    } else {
      return ListView.builder(/* List layout */);
    }
  },
)
```

### Dialog Management
```dart
void _showEditEventDialog(BuildContext context, dynamic event) {
  showDialog(
    context: context,
    builder: (context) => EventFormDialog(
      event: event,
      onSave: (eventData) async {
        try {
          // Update logic
          ref.invalidate(eventsProvider);
          if (mounted) {
            Navigator.of(context).pop(); // Close dialog
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Event updated')),
            );
          }
        } catch (e) {
          // Error handling
        }
      },
    ),
  );
}
```

## Common Issues Fixed
- PopupMenuButton navigation conflicts → Direct IconButton actions
- Dialog not closing → Proper Navigator.pop() implementation
- RenderFlex overflow → mainAxisSize: MainAxisSize.min
- GoRouter assertion errors → Proper navigation handling

## Best Practices
- Always use const constructors when possible
- Implement proper error handling
- Use responsive design patterns
- Handle text overflow gracefully
- Implement proper loading states
- Use proper navigation patterns
