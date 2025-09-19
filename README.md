# burning

App Name: Burning
This Flutter project is an app that allows users to view an infinite list of products, search for products by name, and add them to a favorites list.

1. Setup
Clone the repository:
git clone https://github.com/tainguyen6195/burning.git


Navigate to the project directory:
cd burning

Install the dependencies:
flutter pub get

Generate the code for the models:
flutter pub run build_runner build --delete-conflicting-outputs

2. Run the Application
Connect an Android/iOS device or start an emulator, then run the following command from your terminal
flutter run

3. Test the Features
Infinite Scrolling:

Open the app and scroll down to the bottom of the product list.

Observe the debug console or Logcat for logs confirming that new data is being fetched with skip=20, skip=40, and so on.

Searchable List:

Use the search bar at the top of the screen.

Type in a product name (e.g., "Essence").

Observe the debug console to see that the search API (/products/search) is called only after you've stopped typing for a short period of time (debounce).

Favorite Feature:

Tap the heart icon on a product.

The icon should turn red.

Check the debug console for logs confirming that the product has been saved to the local database.

Close and reopen the app; the product should still be marked as a favorite.

4. Project Structure
The project is organized using a layered architecture for readability and maintainability:

lib/models: Contains the data models (Product, ProductResponse) using freezed.

lib/services: Holds the business logic for API and database interactions.

lib/providers: Manages the application's main state using flutter_riverpod.

lib/screens: Contains the main UI screens.

lib/widgets: Contains reusable UI components.