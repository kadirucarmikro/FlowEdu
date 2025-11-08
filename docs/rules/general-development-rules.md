# General Development Rules

## Project Structure
```
lib/
  app/
    di/
    router/
    theme/
  core/
    constants/
    errors/
    utils/
    widgets/
  features/
    [module_name]/
      data/
        - data_sources/
        - models/
        - repositories/
      domain/
        - entities/
        - repositories/
        - use_cases/
      presentation/
        - pages/
        - widgets/
        - providers/
  services/
    supabase/
  main.dart
```

## Code Quality Rules

### Naming Conventions
- **Classes**: PascalCase (e.g., `EventCard`, `PaymentForm`)
- **Variables/Functions**: camelCase (e.g., `eventData`, `handlePayment`)
- **Files**: snake_case (e.g., `event_card.dart`, `payment_form.dart`)
- **Constants**: UPPER_SNAKE_CASE (e.g., `MAX_RETRY_COUNT`)

### Error Handling
```dart
// Always use try-catch blocks
try {
  final result = await repository.getData();
  // Handle success
} catch (e) {
  // Log error
  debugPrint('Error: $e');
  // Show user-friendly message
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('An error occurred: ${e.toString()}')),
  );
}
```

### State Management (Riverpod)
```dart
// Use FutureProvider for async data
final eventsProvider = FutureProvider<List<Event>>((ref) async {
  final repository = ref.read(eventsRepositoryProvider);
  return repository.getEvents();
});

// Use Provider for use cases
final createEventProvider = Provider<CreateEventUseCase>((ref) {
  return CreateEventUseCase(ref.read(eventsRepositoryProvider));
});

// Always invalidate after mutations
ref.invalidate(eventsProvider);
```

### Responsive Design
```dart
// Use LayoutBuilder for responsive layouts
LayoutBuilder(
  builder: (context, constraints) {
    final isWideScreen = constraints.maxWidth > 600;
    if (isWideScreen) {
      return GridView.builder(/* Grid layout */);
    } else {
      return ListView.builder(/* List layout */);
    }
  },
)

// Implement proper breakpoints
final crossAxisCount = constraints.maxWidth > 1400 ? 4 : 
                      constraints.maxWidth > 1000 ? 3 : 
                      constraints.maxWidth > 700 ? 2 : 1;
```

### Navigation (GoRouter)
```dart
// Avoid Navigator.pop() conflicts
// Use proper context handling
void _showDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      // Dialog content
    ),
  );
}

// Handle dialog closing properly
Navigator.of(context).pop();
```

### Dialog Management
```dart
// Avoid PopupMenuButton conflicts
// Use direct IconButton actions
Row(
  children: [
    IconButton(
      icon: Icon(Icons.edit),
      onPressed: onEdit,
    ),
    IconButton(
      icon: Icon(Icons.delete),
      onPressed: onDelete,
    ),
  ],
)
```

### Performance Optimization
```dart
// Use const constructors when possible
const Text('Hello World')

// Implement proper loading states
if (isLoading) {
  return CircularProgressIndicator();
}

// Use efficient list builders
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(items[index]),
)
```

## Common Issues and Solutions

### 1. PopupMenuButton Navigation Conflicts
**Problem**: PopupMenuButton causes GoRouter assertion errors
**Solution**: Use direct IconButton actions instead

### 2. Dialog Not Closing
**Problem**: Dialog doesn't close after operations
**Solution**: Implement proper Navigator.pop() after successful operations

### 3. RenderFlex Overflow
**Problem**: Text overflows in cards
**Solution**: Use maxLines and TextOverflow.ellipsis

### 4. Responsive Layout Issues
**Problem**: Layout doesn't adapt to screen size
**Solution**: Use LayoutBuilder with proper breakpoints

### 5. State Management Issues
**Problem**: State not updating properly
**Solution**: Use ref.invalidate() after mutations

## Testing Rules
- Test all CRUD operations
- Test responsive design on different screen sizes
- Test error handling scenarios
- Test navigation flows
- Test dialog interactions
- Test state management

## Documentation Rules
- Document all public methods
- Add inline comments for complex logic
- Update README for new features
- Keep technical analysis updated
- Document API changes
