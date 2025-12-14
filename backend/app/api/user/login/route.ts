import { NextResponse } from 'next/server';
import { firestore } from '@/lib/firebaseAdmin';

export async function POST(request: Request) {
    try {
        const userData = await request.json();

        // ID logic: If _id is passed, use it? Or use phone/email to find?
        // The AppState sends `user.toJson()`. models.dart maps `id` to `_id`.
        // So we receive `_id`.

        let userId = userData._id;
        const usersRef = firestore.collection('users');

        // Remove _id from data to save
        const { _id, ...dataToSave } = userData;

        if (userId && !userId.startsWith("new_") && !userId.startsWith("temp_")) {
            // Update existing
            await usersRef.doc(userId).set(dataToSave, { merge: true });
        } else {
            // Create new
            // Check if exists by email/phone first to avoid duplicates
            let existingDoc;
            if (userData.email) {
                const s = await usersRef.where('email', '==', userData.email).limit(1).get();
                if (!s.empty) existingDoc = s.docs[0];
            }

            if (!existingDoc && userData.phone) {
                const s = await usersRef.where('phone', '==', userData.phone).limit(1).get();
                if (!s.empty) existingDoc = s.docs[0];
            }

            if (existingDoc) {
                userId = existingDoc.id;
                await existingDoc.ref.set(dataToSave, { merge: true });
            } else {
                const docRef = await usersRef.add(dataToSave);
                userId = docRef.id;
            }
        }

        // Return updated user
        const finalDoc = await usersRef.doc(userId).get();
        const finalData = finalDoc.data() || {};
        finalData._id = finalDoc.id;

        return NextResponse.json({
            statusCode: 200, // App expects 200 not 201 sometimes? api.dart simply returns handleResponse
            message: "User Logged In",
            body: finalData
        });

    } catch (error) {
        console.error(error);
        return NextResponse.json({ statusCode: 500, message: "Server Error" });
    }
}
