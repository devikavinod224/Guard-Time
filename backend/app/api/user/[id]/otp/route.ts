import { NextResponse } from 'next/server';
import { firestore } from '@/lib/firebaseAdmin';

export async function GET(request: Request, context: { params: Promise<{ id: string }> }) {
    const { id } = await context.params;
    const phone = id;
    console.log(`Sending OTP to ${phone}`);
    return NextResponse.json({ statusCode: 200, message: "OTP sent successfully (Mock: 123456)" });
}

export async function POST(request: Request, context: { params: Promise<{ id: string }> }) {
    const { id } = await context.params;
    const phone = id;
    try {
        const body = await request.json();
        const { otp } = body;

        if (otp === '123456') {
            const usersRef = firestore.collection('users');
            const snapshot = await usersRef.where('phone', '==', phone).limit(1).get();

            let userData;
            if (snapshot.empty) {
                // Return a temporary user object so the app can proceed to sign up
                userData = {
                    _id: "new_" + phone,
                    phone: phone,
                    firstName: "Guest",
                    lastName: "User",
                    devices: []
                };
            } else {
                const doc = snapshot.docs[0];
                userData = doc.data();
                userData._id = doc.id;
            }

            return NextResponse.json({
                statusCode: 200,
                message: "OTP Verified",
                body: userData
            });
        } else {
            return NextResponse.json({ statusCode: 400, message: "Invalid OTP" });
        }
    } catch (error) {
        console.error(error);
        return NextResponse.json({ statusCode: 500, message: "Server Error" });
    }
}
