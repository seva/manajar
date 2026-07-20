import type { NextApiRequest, NextApiResponse } from 'next'

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse
) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' })
  }

  const { userId } = req.body

  if (!userId) {
    return res.status(400).json({ error: 'Missing userId' })
  }

  try {
    // Request device code from xAI
    const deviceCodeResponse = await fetch('https://accounts.x.ai/oauth/device/code', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        client_id: process.env.XAI_CLIENT_ID || '',
        scope: 'openid profile email',
      }),
    })

    if (!deviceCodeResponse.ok) {
      const error = await deviceCodeResponse.text()
      console.error('Device code request failed:', error)
      return res.status(500).json({ error: 'Failed to request device code' })
    }

    const deviceData = await deviceCodeResponse.json()

    // Return device code info to the game
    return res.status(200).json({
      success: true,
      userId,
      provider: 'grok',
      deviceCode: deviceData.device_code,
      userCode: deviceData.user_code,
      verificationUri: deviceData.verification_uri,
      expiresIn: deviceData.expires_in,
      interval: deviceData.interval,
    })
  } catch (error) {
    console.error('Device code error:', error)
    return res.status(500).json({ error: 'Internal server error' })
  }
}
