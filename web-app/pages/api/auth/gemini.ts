import type { NextApiRequest, NextApiResponse } from 'next'

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse
) {
  const { code, state } = req.query

  if (!code || !state) {
    return res.status(400).json({ error: 'Missing code or state parameter' })
  }

  // Extract userId from state (we'll encode it in the state parameter)
  const userId = state as string

  try {
    // Exchange authorization code for tokens
    const tokenResponse = await fetch('https://oauth2.googleapis.com/token', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: new URLSearchParams({
        code: code as string,
        client_id: process.env.GOOGLE_CLIENT_ID || '',
        client_secret: process.env.GOOGLE_CLIENT_SECRET || '',
        redirect_uri: `${process.env.NEXT_PUBLIC_APP_URL}/api/auth/gemini`,
        grant_type: 'authorization_code',
      }),
    })

    if (!tokenResponse.ok) {
      const error = await tokenResponse.text()
      console.error('Token exchange failed:', error)
      return res.status(500).json({ error: 'Failed to exchange code for tokens' })
    }

    const tokens = await tokenResponse.json()

    // Store tokens (for now, return them in the response - in production, use a database)
    // In production, you'd store these in a database keyed by userId
    // For now, we'll return them so the Roblox client can retrieve them

    return res.status(200).json({
      success: true,
      userId,
      provider: 'gemini',
      accessToken: tokens.access_token,
      refreshToken: tokens.refresh_token,
      expiresAt: Date.now() + (tokens.expires_in * 1000),
    })
  } catch (error) {
    console.error('OAuth callback error:', error)
    return res.status(500).json({ error: 'Internal server error' })
  }
}
