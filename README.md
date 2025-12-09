# mpx_1635

RemindDb

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.



-----

## Pitch
RemindDb aims to solve a common problem. Often, people will have a list on their phone of movies, books, tv-shows, music, etc. that they plan to consume at a later time. But really, how often do we ever get back to these? We noticed that every platform has their own "watch later" or "add-to-list" button, but what if there was a way to have all of these lists in one place where you can easily find, and store all of your desired media titles?

Why RemindDb is different:
RemindDb stands out from other organization apps and tools because it isn't simple a bullet-point list. When you discover new media titles, you can have them stored in one place with easy and convient ways to come back to them later. 

{For the purposes of our project and time restraints, we only used one API, but in a production app, full functionality would be required}

## API(s)
The only API we went with was Google Books API. We chose this because it was fast, free, and offered most of what we wanted.

## MVVM
Book (media_model.dart): 
        data-only representation of a book (id, title, authors, synopsis, coverUrl). Example:
            class Book
                Role: pure model — used by ViewModels and Views, contains no UI or async logic.

Playlist (playlist_model.dart):
         DTO for a playlist with toMap() / fromMap() for persistence.

Reminder (remind.dart):
        small model used by the notifier:
             class Reminder { final String id; final String bookId; final String frequency; }

Summary: These only represent data and provide serialization; they do not manipulate UI state or perform network/timer work.

## ViewModels / views
SearchService / GoogleBooksSearchService / OpenLibraryBookService:
        Responsibilities: perform HTTP searches, fetch book details, combine author info, return Book objects.
        Example usage: final book = await _searchService.fetchBookById(fullBook.id); in MediaPage.
        Role: pure business logic / network layer — View calls these to get data.

RemindNotifier (remind.dart):
        Implements ChangeNotifier; stores an in-memory list of Reminders and exposes addReminder, removeReminder and reminders.
        Acts as a small ViewModel for any UI that needs to show the list of reminders (binding via a listener or provider).

RemindService (added in remind_service.dart):
        Singleton that schedules timers independent of widget lifecycle and triggers the UI overlay via global navigatorKey.
        Responsibility: scheduling and firing reminders, decoupled from any particular page (important for cross-page reminders).

PlaylistRepository (from the MediaPage):
         repository-like ViewModel that manages storing playlists and updating them.

Summary: These operations orchestrate async calls, transform/prepare model data, and execute methods such as scheduleReminder, searchBooks, addReminder, and they they do not render UI.


