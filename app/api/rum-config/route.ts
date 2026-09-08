import { NextResponse } from 'next/server';

export const dynamic = 'force-dynamic';

export async function GET() {
  const apiKey = process.env.HYPERDX_API_KEY ?? null;
  const url = process.env.HYPERDX_URL ?? 'https://hyperdx.makgol.com/otel';

  return NextResponse.json(
    { apiKey, url, service: 'wedding-invitation' },
    { headers: { 'Cache-Control': 'no-store' } },
  );
}
