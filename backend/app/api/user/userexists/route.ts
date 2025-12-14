import { NextResponse } from 'next/server';
import { firestore } from '@/lib/firebaseAdmin';

export async function POST(request: Request) {
    try {
        const body = await request.json();
        const { phone, email } = body;

        const usersRef = firestore.collection('users');
        let query = usersRef.where('phone', '==', phone);

        // Also check email if provided? The app sends both.
        // Simplifying to check phone first. 
        // Ideally we check (phone OR email). Firestore doesn't support logical OR directly in one query easily without multiple queries.
        // Let's check phone.

        let snapshot = await query.limit(1).get();

        if (snapshot.empty && email) {
            snapshot = await usersRef.where('email', '==', email).limit(1).get();
        }

        if (!snapshot.empty) {
            const doc = snapshot.docs[0];
            const userData = doc.data();
            userData._id = doc.id;
            return NextResponse.json({
                statusCode: 200,
                message: "User found",
                body: userData
            });
        } else {
            return NextResponse.json({
                statusCode: 205,
                message: "User not found"
            });
        }
    } catch (error) {
        console.error(error);
        return NextResponse.json({ statusCode: 500, message: "Server Error" });
    }
}
