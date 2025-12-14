# Guard Time Backend

This is a Next.js backend

## Setup

1.  **Install Dependencies**:
    ```bash
    npm install
    ```

2.  **Environment Variables**:
    Create a file named `.env.local` in this directory.
    Copy the contents from `env.example` and fill in your Firebase Admin SDK details.
    
    To get these details:
    -   Go to Firebase Console -> Project Settings -> Service Accounts.
    -   Click "Generate new private key".
    -   Open the downloaded JSON file.
    -   Copy `project_id` to `FIREBASE_PROJECT_ID`.
    -   Copy `client_email` to `FIREBASE_CLIENT_EMAIL`.
    -   Copy `private_key` to `FIREBASE_PRIVATE_KEY` (Keep the `\n` characters).

3.  **Run Locally**:
    ```bash
    npm run dev
    ```
    The server will start at `http://localhost:3000`.

## API Endpoints with Mocking
-   **OTP**: `GET /api/user/:phone/otp` will ALWAYS return success. The OTP code is `1234`.
-   **Login**: Uses your Firestore database to save users.
