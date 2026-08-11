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

Data lives on the authenticated `users/{uid}` docs and under
`apartments/{aptId}/…` subcollections (`aptId` defaults to `default_apt`).
All streams rebuild in real time, so changes appear instantly. Empty
collections show friendly empty states, so the app runs either way.

| Collection | Fields | Used for |
|------------|--------|----------|
| `users/{uid}` | `email`, `displayName`, `apartmentId`, `createdAt` | Auth profiles, the apartment's **member list**, and the task-assignee dropdown |
| `apartments/{aptId}/chores` | `title`, `assignedTo`, `assignedToId`, `category`, `priority`, `isDone`, `createdAt` | Chore board + dashboard |
| `apartments/{aptId}/expenses` | `title`, `totalAmount`, `splitCount`, `breakdown` (map), `createdAt` | Expense splitter + dashboard |
| `apartments/{aptId}/notices` | `title`, `content`, `author`, `authorId`, `createdAt` | Notice board |
| `apartments/{aptId}/chatrooms/{roomId}` | `name`, `isDefault`, `lastMessage`, `lastMessageAt`, `createdAt` | Chatroom list |
| `…/chatrooms/{roomId}/messages` | `text`, `senderName`, `senderId`, `createdAt` | Chat thread |

Members are the real Firestore users whose `users/{uid}.apartmentId` matches the
current apartment — so a task can only be assigned to a member that actually
exists in Firebase. A built-in "General" chatroom is auto-created on first
launch.

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

