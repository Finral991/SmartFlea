# Firebase rules for SmartFlea

Paste these rules into **Firebase Console → Firestore Database → Rules** and publish them.

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function signedIn() { return request.auth != null; }
    function ownUser(userId) { return signedIn() && request.auth.uid == userId; }
    function admin() {
      return signedIn() && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }

    match /users/{userId} {
      allow read: if signedIn();
      allow create: if ownUser(userId) && request.resource.data.role == 'user';
      allow update: if ownUser(userId)
        && request.resource.data.role == resource.data.role
        && request.resource.data.username == resource.data.username;
      allow update, delete: if admin();
    }

    match /usernames/{username} {
      allow read: if true;
      allow create: if signedIn() && request.resource.data.uid == request.auth.uid;
      allow update, delete: if false;
    }

    match /posts/{postId} {
      allow read: if true;
      allow create, update, delete: if admin();
    }

    match /posts/{postId}/comments/{commentId} {
      allow read: if true;
      allow create: if signedIn() && request.resource.data.authorId == request.auth.uid;
      allow update, delete: if signedIn() && resource.data.authorId == request.auth.uid || admin();
    }

    match /chats/{chatId} {
      allow read, create: if signedIn() && request.auth.uid in request.resource.data.members;
      allow update: if signedIn() && request.auth.uid in resource.data.members;
      match /messages/{messageId} {
        allow read: if signedIn() && request.auth.uid in get(/databases/$(database)/documents/chats/$(chatId)).data.members;
        allow create: if signedIn() && request.auth.uid in get(/databases/$(database)/documents/chats/$(chatId)).data.members && request.resource.data.senderId == request.auth.uid;
      }
    }
  }
}
```

For Storage, start with this minimal authenticated rule, then refine file-size/type limits:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /avatars/{userId}/{fileName} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId && request.resource.size < 2 * 1024 * 1024;
    }
    match /chat-files/{chatId}/{fileName} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.resource.size < 5 * 1024 * 1024;
    }
  }
}
```

## First administrator

1. Register your account through the site.
2. In Firestore, open `users` → your UID document.
3. Change `role` from `user` to `admin`.

Only do this after the Firestore rules are published. The application will later use this role for the admin panel.
