import * as admin from 'firebase-admin';

let firestore: admin.firestore.Firestore;
let auth: admin.auth.Auth;

// Prevent multiple initializations
if (admin.apps.length > 0) {
    firestore = admin.firestore();
    auth = admin.auth();
} else {
    // Check if credentials exist
    if (
        process.env.FIREBASE_PROJECT_ID &&
        process.env.FIREBASE_CLIENT_EMAIL &&
        process.env.FIREBASE_PRIVATE_KEY
    ) {
        try {
            admin.initializeApp({
                credential: admin.credential.cert({
                    projectId: process.env.FIREBASE_PROJECT_ID,
                    clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
                    privateKey: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
                }),
                databaseURL: process.env.FIREBASE_DATABASE_URL,
            });
            firestore = admin.firestore();
            auth = admin.auth();
        } catch (error) {
            console.error('Firebase Admin Init Error:', error);
            // Fallback for build time
            firestore = {} as admin.firestore.Firestore;
            auth = {} as admin.auth.Auth;
        }
    } else {
        // Missing credentials - likely build time or misconfiguration
        console.warn(
            '⚠️ Firebase Admin credentials missing. Skipping initialization. APIs will fail if called.'
        );
        // Export mocks to allow 'next build' to pass without crashing on import
        firestore = {} as admin.firestore.Firestore;
        auth = {} as admin.auth.Auth;
    }
}

export { firestore, auth };
