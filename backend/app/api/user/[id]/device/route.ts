import { NextResponse } from 'next/server';
import { firestore } from '@/lib/firebaseAdmin';

export async function GET(request: Request, context: { params: Promise<{ id: string }> }) {
    const { id } = await context.params;
    try {
        // We store devices in a subcollection of the user for direct ownership mapping
        const snapshot = await firestore.collection('users').doc(id).collection('devices').get();
        const devices = snapshot.docs.map(doc => {
            const d = doc.data();
            d._id = doc.id;
            return d;
        });
        return NextResponse.json({ statusCode: 200, message: "Success", devices: devices });
    } catch (e) {
        console.error(e);
        return NextResponse.json({ statusCode: 500, message: "Server Error" });
    }
}
