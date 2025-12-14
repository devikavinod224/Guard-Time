import { NextResponse } from 'next/server';
import { firestore } from '@/lib/firebaseAdmin';

export async function PUT(request: Request, context: { params: Promise<{ id: string, deviceId: string }> }) {
    const { id, deviceId } = await context.params;
    try {
        const body = await request.json();

        // Remove _id from body if present
        const { _id, ...data } = body;

        await firestore.collection('users').doc(id).collection('devices').doc(deviceId).set(data, { merge: true });

        const updated = await firestore.collection('users').doc(id).collection('devices').doc(deviceId).get();
        const resData = updated.data() || {};
        resData._id = updated.id;

        return NextResponse.json({ statusCode: 200, message: "Device Updated", body: resData });
    } catch (e) {
        console.error(e);
        return NextResponse.json({ statusCode: 500, message: "Server Error" });
    }
}
