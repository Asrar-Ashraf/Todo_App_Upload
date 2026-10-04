<div align="center">

# ✅ TaskFlow

### 📝 Plan your day. Stay on track. Get things done.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Material 3](https://img.shields.io/badge/Material%203-34D399?style=for-the-badge&logo=materialdesign&logoColor=white)
![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)
![Status](https://img.shields.io/badge/Status-Completed-22D3EE?style=for-the-badge)

</div>

---

## 📖 About

**TaskFlow** is a modern to-do app built with Flutter, featuring a clean dark design and smooth animations. 🌙✨

Add tasks step by step, organize them by category, mark your favourites ❤️, and get a reminder 🔔 at the exact time you choose. Everything is saved on your phone 💾, so your tasks are still there when you reopen the app.

---

## 📸 Screenshots

<div align="center">

| 🚀 Splash | 🏠 Home | 🗂️ Select Task Type | 🎯 Final |
|:---------:|:-------:|:-------------------:|:--------:|
| [<img src="assets/images/splash.jpeg" width="200" alt="Splash">](assets/images/splash.jpeg) | [<img src="assets/images/home.jpeg" width="200" alt="Home">](assets/images/home.jpeg) | [<img src="assets/images/tashSelect.jpeg" width="200" alt="Select Task Type">](assets/images/tashSelect.jpeg) | [<img src="assets/images/final.jpeg" width="200" alt="Final">](assets/images/final.jpeg) |

*👆 Click any screenshot to view it in full size.*

</div>

---

## ✨ Features

| | Feature | Description |
|---|---------|-------------|
| 🧭 | **Step-by-step Add Task** | Choose type, write details, set priority, pick date and time, then review |
| 🗂️ | **Categories** | Home 🏠, Office 💼, Study 📚, Shopping 🛒, Health ❤️‍🩹 and Other ✨ |
| 🚦 | **Priority levels** | Low 🟢, Medium 🟡 and High 🔴 with colour coding |
| 🔔 | **Reminders** | Get notified at the due time, 10 minutes or 1 hour before |
| ❤️ | **Favourites** | Mark important tasks and view them in a separate tab |
| 🔍 | **Search and filters** | All, Active, Favourites and Completed |
| 📊 | **Progress tracker** | See how many tasks you have completed |
| 🗑️ | **Delete with Undo** | Swipe to delete, and bring it back with Undo |
| 🔒 | **Locked completed tasks** | Completed tasks cannot be edited or marked pending again |
| 💾 | **Local storage** | Your tasks stay saved after closing the app |
| 🎨 | **Modern design** | Dark Material 3 look with smooth animations |

---

## 🔄 How It Works

```
🚀 Splash ──► 🏠 Home ──► ➕ New Task
                              │
        🗂️ Type ─► ✍️ Details ─► 🚦 Priority ─► 📅 Due date ─► ✅ Review
                              │
                              ▼
            🔔 Reminder  ·  ❤️ Favourite  ·  ✔️ Complete  ·  🗑️ Delete
```

---

## 🛠️ Tech Stack

| 📦 Package | 🎯 Purpose |
|------------|-----------|
| `provider` | State management |
| `shared_preferences` | Local storage |
| `flutter_local_notifications` | Task reminders |
| `timezone` + `flutter_timezone` | Correct reminder times |
| `google_fonts` | Poppins and Inter fonts |
| `flutter_animate` | Smooth animations |

---

## 📂 Project Structure

```
lib/
├── main.dart
├── 🎨 theme/        → colors, fonts, shapes
├── 🧩 models/       → Task model
├── ⚙️ services/     → storage and notifications
├── 🧠 providers/    → task state (add, edit, delete, complete, favourite)
├── 📱 screens/      → splash and home screens
├── 🧱 widgets/      → task card, add/edit wizard, reusable widgets
├── 🔧 utils/        → snackbar helper
└── 💡 data/         → quick task suggestions
```

---

## 🚀 Getting Started

**1️⃣ Clone the repository**
```bash
git clone <your-repo-link>
cd todo_app
```

**2️⃣ Install dependencies**
```bash
flutter pub get
```

**3️⃣ Run the app** on an Android phone or emulator
```bash
flutter run
```

> 💡 **Note:** Reminder notifications work on Android and iOS only (not on web or desktop). On some phones (Realme, Oppo, Xiaomi), set the app's battery usage to **Unrestricted** so reminders arrive on time. 🔋

---

## 👨‍💻 Author

**Muhammad Asrar**
📱 Flutter Developer

[![GitHub](https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/Asrar-Ashraf)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://linkedin.com/in/muhammad-asrar-ashraf)

---

<div align="center">

⭐ **If you like this project, give it a star!** ⭐

Made with ❤️ using Flutter

</div>
