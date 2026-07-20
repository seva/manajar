import type { NextApiRequest, NextApiResponse } from 'next'

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse
) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' })
  }

  const { userId, deviceCode } = req.body

  if (!userId || !deviceCode) {
    return res.status(400).json({ error: 'Missing userId or deviceCode' })
  }

  try {
    // Poll xAI for token
    const tokenResponse = await fetch('https://accounts.x.ai/oauth/token', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        grant_type: 'urn:ietf:params:oauth:grant-type:device_code',
        device_code: deviceCode,
        client_id: process.env.XAI_CLIENT_ID || '',
      }),
    })

    if (!tokenResponse.ok) {
      const error = await tokenResponse.json()
      
      // Check if authorization is still pending
      if (error.error === 'authorization_pending') {
        return res.status(200).json({
          success: false,
          status: 'pending',
          message: 'Authorization pending',
        })
      }

      if (error.error === 'slow_down') {
        return res.status(200).json({
          success: false,
          status: 'slow_down',
          message: 'Please slow down polling',
        })
      }

      if (error.error === 'expired_token') {
        return res.status(200).json({
          success: false,
          status: 'expired',
          message: 'Device code expired',
        })
      }

      if (error.error === 'access_denied') {
        return res.status(200).json({
          success: false,
          status: 'denied',
          message: 'Access denied',
        })
      }

      console.error('Token poll failed:', error)
      return res.status(500).json({ error: 'Failed to poll for token' })
    }

    const tokens = await tokenResponse.json()

    // Return tokens to Roblox
    return res.status(200).json({
      success: true,
      userId,
      provider: 'grok',
      accessToken: tokens.access_token,
      refreshToken: tokens.refresh_token,
      expiresAt: Date.now() + (tokens.expires_in * 1000),
    })
  } catch (error) {
    console.error('Token poll error:', error)
    return res.status(500).json({ error: 'Internal server error' })
  }
}
