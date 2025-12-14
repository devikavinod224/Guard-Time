import { NextResponse } from 'next/server';

export async function GET(request: Request) {
    // Mock offers
    const offers = [
        {
            _id: "offer_1",
            title: "Standard Plan",
            desc: "Protect up to 3 devices",
            tokenCount: 1,
            tenure: "1 Year",
            originalPrice: 999,
            discountedPrice: 499,
            gst: 18,
            benefits: ["App Blocking", "Location Tracking"],
            validUntil: "2025-12-31",
            isActive: true
        }
    ];
    return NextResponse.json({ statusCode: 200, message: "Offers fetched", body: offers });
}
