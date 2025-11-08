# Payments Module Rules

## Module Status: 📋 NEXT PRIORITY

## Architecture Requirements
- Clean Architecture implementation
- Riverpod state management
- Supabase integration
- Responsive design
- GoRouter navigation

## Key Features to Implement
- Payment creation and management
- Package fee management
- Discount system
- Payment history and reporting
- Payment status tracking

## Code Patterns to Follow

### Payment Card Design
```dart
class PaymentCard extends StatelessWidget {
  // Use direct IconButton actions
  // Implement proper overflow handling
  // Use responsive design
  // Show payment status clearly
  // Display amount and discount information
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

### Payment Form Dialog
```dart
void _showPaymentFormDialog(BuildContext context, {dynamic payment}) {
  showDialog(
    context: context,
    builder: (context) => PaymentFormDialog(
      payment: payment,
      onSave: (paymentData) async {
        try {
          // Payment logic
          ref.invalidate(paymentsProvider);
          if (mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Payment saved')),
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

## Database Schema
```sql
-- Payments table structure
create table if not exists public.payments (
  id uuid primary key default gen_random_uuid(),
  member_id uuid not null references public.members(id) on delete cascade,
  package_id uuid not null references public.lesson_packages(id) on delete restrict,
  amount numeric(10,2) not null check (amount >= 0),
  discount_amount numeric(10,2) not null default 0 check (discount_amount >= 0),
  status payment_status not null default 'pending',
  due_date date,
  paid_at timestamptz,
  created_at timestamptz not null default now()
);
```

## RLS Policies to Implement
```sql
-- Payments: owner or admin can read; only admin can write
drop policy if exists payments_read on public.payments;
create policy payments_read on public.payments
for select using (
  public.is_admin() or exists (
    select 1 from public.members m where m.id = payments.member_id and m.user_id = auth.uid()
  )
);

drop policy if exists payments_write on public.payments;
create policy payments_write on public.payments
for all using (public.is_admin()) with check (public.is_admin());
```

## Implementation Steps
1. Create Clean Architecture structure
2. Implement data sources and repositories
3. Create domain entities and use cases
4. Build presentation layer with Riverpod
5. Implement responsive UI
6. Add proper error handling
7. Implement RLS policies
8. Test thoroughly

## Best Practices
- Follow existing module patterns
- Implement proper validation
- Use responsive design
- Handle errors gracefully
- Implement proper loading states
- Use secure data access patterns
- Follow Clean Architecture principles
