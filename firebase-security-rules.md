# Firebase Security Rules for SmartFlea

Оскільки Firebase Storage вимкнено, тепер використовується **лише безкоштовний Cloud Firestore Database** (в межах безкоштовного тарифного плану Spark, без прив'язки картки).

Вам потрібно налаштувати **лише одне вікно правил** у Firebase Console:

📍 **Firebase Console → Firestore Database → вкладка Rules** → вставте наведений нижче код → натисніть **Publish**.

---

## Cloud Firestore Rules

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    // Допоміжні функції перевірки
    function signedIn() {
      return request.auth != null;
    }

    function own(userId) {
      return signedIn() && request.auth.uid == userId;
    }

    function admin() {
      return signedIn()
        && exists(/databases/$(database)/documents/users/$(request.auth.uid))
        && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }

    function editor() {
      return signedIn()
        && exists(/databases/$(database)/documents/users/$(request.auth.uid))
        && (
          get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin'
          || get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'editor'
        );
    }

    // Дозвіл на початкове автостворення карток test1...test9.
    // Надалі змінювати їх можуть лише editor або admin.
    function initialTestPost(postId) {
      return signedIn()
        && postId.matches('test[1-9]')
        && request.resource.data.isSeedPost == true
        && request.resource.data.keys().hasAll([
          'title',
          'imageUrl',
          'description',
          'keywords',
          'isSeedPost',
          'createdAt',
          'updatedAt'
        ]);
    }

    // ---------------- ПРОФІЛІ КОРИСТУВАЧІВ ----------------
    match /users/{userId} {
      // Будь-який авторизований користувач може бачити список користувачів (для чату/пошуку)
      allow read: if signedIn();

      // Створення профілю при реєстрації з базовою роллю 'user'
      allow create: if own(userId)
        && request.resource.data.role == 'user'
        && request.resource.data.keys().hasAll([
          'fullName',
          'email',
          'dateOfBirth',
          'gender',
          'country',
          'createdAt'
        ]);

      // Користувач може оновлювати свій профіль, але не може сам підвищити свою роль або змінити username
      allow update: if own(userId)
        && request.resource.data.role == resource.data.role
        && (!('username' in resource.data) || request.resource.data.username == resource.data.username);

      // Адміністратор може редагувати ролі або видаляти користувачів
      allow update, delete: if admin();
    }

    // ---------------- УНІКАЛЬНІ ЮЗЕРНЕЙМИ ----------------
    match /usernames/{username} {
      allow get: if true;
      allow list: if false;

      allow create: if signedIn()
        && request.resource.data.uid == request.auth.uid;

      allow update, delete: if admin();
    }

    // ---------------- СТАТТІ ТА ПОСТИ ----------------
    match /posts/{postId} {
      // Статті можуть читати всі відвідувачі
      allow read: if true;

      // Editor та admin можуть створювати будь-які пости. Звичайні користувачі — тільки відсутні test1...test9
      allow create: if editor() || initialTestPost(postId);

      // Редагувати пости можуть editor та admin
      allow update: if editor();

      // Видаляти пости може лише admin
      allow delete: if admin();

      // Коментарі до постів
      match /comments/{commentId} {
        allow read: if true;

        allow create: if signedIn()
          && request.resource.data.authorId == request.auth.uid;

        allow update, delete: if (
          signedIn()
          && resource.data.authorId == request.auth.uid
        ) || admin();
      }

      // Оцінки/рейтинги до постів
      match /ratings/{userId} {
        allow read: if true;

        allow create, update: if signedIn()
          && request.auth.uid == userId;

        allow delete: if (
          signedIn()
          && request.auth.uid == userId
        ) || admin();
      }
    }

    // ---------------- ЧАТИ ТА ПОВІДОМЛЕННЯ ----------------
    match /chats/{chatId} {
      // Читати інформацію про чат може лише учасник
      allow read: if signedIn()
        && request.auth.uid in resource.data.members;

      // Створювати direct-чат або групу може будь-хто з учасників
      allow create: if signedIn()
        && request.auth.uid in request.resource.data.members;

      // Оновлення чату:
      // - Учасники оновлюють поля технічного стану (updatedAt, lastMessage)
      // - Власник групи (ownerId) може додавати або видаляти учасників
      // - Адміністратор має повний доступ
      allow update: if signedIn()
        && request.auth.uid in resource.data.members
        && (
          (
            request.resource.data.diff(resource.data)
              .affectedKeys()
              .hasOnly(['updatedAt', 'lastMessage', 'members', 'type'])
            && request.resource.data.members == resource.data.members
          )
          || (
            resource.data.type == 'group'
            && resource.data.ownerId == request.auth.uid
          )
          || admin()
        );

      // Видаляти чат може власник групи або адміністратор
      allow delete: if signedIn()
        && (
          (
            resource.data.type == 'group'
            && resource.data.ownerId == request.auth.uid
          )
          || admin()
        );

      // Підколекція повідомлень чату
      match /messages/{messageId} {
        allow read: if signedIn()
          && request.auth.uid in get(
            /databases/$(database)/documents/chats/$(chatId)
          ).data.members;

        allow create: if signedIn()
          && request.auth.uid in get(
            /databases/$(database)/documents/chats/$(chatId)
          ).data.members
          && request.resource.data.senderId == request.auth.uid;

        // Видалення: автор повідомлення або адміністратор
        allow delete: if signedIn()
          && (
            resource.data.senderId == request.auth.uid
            || admin()
          );
      }
    }
  }
}
```

---

## Як призначити собі роль `admin` або `editor`:

1. Зареєструйтесь на сайті зі своєю поштою.
2. Відкрийте **Firebase Console → Firestore Database → вкладка Data**.
3. У колекції `users` відкрийте документ із вашим `UID`.
4. Змініть значення поля `role` з `"user"` на `"admin"` (для адміна) або `"editor"` (для редактора).
5. Відкрийте сторінку `profile.html` на сайті — з'явиться кнопка **⚙ OPEN ADMIN CONSOLE** або **⚙ OPEN EDITOR PANEL**.
