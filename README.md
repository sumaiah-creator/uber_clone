# uber_clone

 This is a simplified Uber Clone app built using Flutter. The app provides basic functionalities such as user registration and login,viewing the user's current location, searching for destinations, displaying nearby drivers, and requesting a ride. 


## Backend Integration
- Simulated backend integration to fetch drivers' data and user's location.
- User authentication (login and sign up).

## Features
- User authentication(login and sign-up).
- Display the user's current location on a map.
- Search for a destination.
- Display a list of nearby drivers using dummy data.
- Request a ride (simulated).
## Prerequisites

- Flutter SDK: [Install Flutter](https://flutter.dev/docs/get-started/install)
- Android Studio or Visual Studio Code
- A physical or virtual device to run the app
## Getting Started

1. **Clone the repository**:
   
   git clone https://github.com/harshavardhanreddy05/uber_clone.git
   cd uber_clone

2.  **Install dependencies:**:
     flutter pub get
3.  **Set up Firebase:**
- Create a Firebase project in the Firebase Console.
- Add your Android and iOS apps to the Firebase project
- Download the google-services.json file for Android and place it in the android/app directory.
- Ensure that your pubspec.yaml includes the required Firebase dependencies.
    - dependencies:
       firebase_core: latest_version
       firebase_auth: latest_version

4.  **Run the app:**
     flutter run

## Usage

1. **User Authentication:**

   - Sign up or log in using the provided form.

2. **Home Screen:**

  - View the current location on the map.
  - Use the search bar to search for a destination.
  - View the list of available drivers near your location.
- Click the button to request a ride.
3. **Request a Ride:**

   - Simulate the ride request and view the details of the request including driver information and estimated arrival time.
## Backend Integration
   - This project integrates with a fully-functional backend service to provide real-time data and seamless user interactions. The backend handles user authentication, driver availability, ride requests, and other core functionalities, offering a comprehensive and realistic ride-sharing experience.
## Error Handling
   - The app includes basic error handling for network issues and other potential errors during user authentication and data fetching.



