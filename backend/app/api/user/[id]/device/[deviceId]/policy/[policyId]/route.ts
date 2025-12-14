import { NextResponse } from 'next/server';
import { firestore } from '@/lib/firebaseAdmin';

export async function PUT(request: Request, context: { params: Promise<{ id: string, deviceId: string }> }) {
    const { id, deviceId } = await context.params;
    try {
        const body = await request.json();
        const policy = body.policyItself;

        await firestore.collection('users').doc(id).collection('devices').doc(deviceId).update({ policy: policy });

        return NextResponse.json({ statusCode: 200, message: "Policy Updated", body: policy });
    } catch (e) {
        console.error(e);
        return NextResponse.json({ statusCode: 500, message: "Server Error" });
    }
}
