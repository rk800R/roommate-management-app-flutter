# roommate

A Flutter roommate / shared-apartment app. **Screen 1** is email+password
authentication (dark glassmorphism UI). **Screen 2** is the dashboard
(`HomeScreen`) — a live summary of the apartment's state streamed from
Cloud Firestore.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

## Firestore data model

The dashboard (`lib/services/DashboardService.dart`) reads four top-level
collections and rebuilds in real time whenever they change. Create them in
the Firebase console (`internship-2026-roommate-app`) and seed a few docs —
empty collections show friendly empty states, so the app runs either way.

| Collection | Fields | Used for |
|------------|--------|----------|
| `members`  | `name` (string), `monthlyDue` (number), `colorSeed` (int, optional) | Total monthly dues + "paid" progress |
| `payments` | `memberId`, `memberName`, `amount` (number), `date` (timestamp), `note` (optional) | Amount already paid this period |
| `chores`   | `title`, `assignedTo`, `category`, `completed` (bool), `dueDate` (timestamp), `points` (int, optional), `description` (optional) | Pending-chores count, today's progress, upcoming list |
| `expenses` | `title`, `amount` (number), `paidBy`, `category`, `date` (timestamp) | Recent-activity feed |

Dues logic: `remaining = Σ monthlyDue − Σ payments.amount`, with `progress =
paid / total`. Currency formatting lives in `AppCurrency` in
`DashboardService.dart` (defaults to `kr`, Icelandic króna) — change the
symbol there to match your region.

## Run

```sh
flutter pub get
flutter run
```

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

