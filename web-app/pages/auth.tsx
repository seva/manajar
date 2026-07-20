import { useEffect, useState } from 'react'
import { useRouter } from 'next/router'

export default function AuthPage() {
  const router = useRouter()
  const { userId, provider } = router.query
  const [status, setStatus] = useState('loading')
  const [error, setError] = useState('')

  useEffect(() => {
    if (!userId || !provider) {
      setError('Missing userId or provider parameter')
      setStatus('error')
      return
    }

    if (provider === 'gemini') {
      // Redirect to Google OAuth
      const params = new URLSearchParams({
        client_id: process.env.NEXT_PUBLIC_GOOGLE_CLIENT_ID || '',
        redirect_uri: `${window.location.origin}/api/auth/gemini`,
        response_type: 'code',
        scope: 'https://www.googleapis.com/auth/generative-language',
        state: userId as string,
        access_type: 'offline',
        prompt: 'consent',
      })
      
      window.location.href = `https://accounts.google.com/o/oauth2/v2/auth?${params.toString()}`
    } else if (provider === 'grok') {
      // For Grok, we need to show device code instructions
      // This will be handled by the Roblox client
      setStatus('grok-instructions')
    } else {
      setError('Invalid provider')
      setStatus('error')
    }
  }, [userId, provider])

  if (status === 'loading') {
    return (
      <div style={{ padding: '2rem', fontFamily: 'system-ui' }}>
        <h1>Connecting LLM Provider...</h1>
        <p>Please wait while we redirect you to authenticate.</p>
      </div>
    )
  }

  if (status === 'error') {
    return (
      <div style={{ padding: '2rem', fontFamily: 'system-ui' }}>
        <h1>Authentication Error</h1>
        <p style={{ color: 'red' }}>{error}</p>
        <p>Please return to the game and try again.</p>
      </div>
    )
  }

  if (status === 'grok-instructions') {
    return (
      <div style={{ padding: '2rem', fontFamily: 'system-ui' }}>
        <h1>Connect xAI Grok</h1>
        <p>To connect your xAI Grok account, please return to the game and follow the on-screen instructions.</p>
        <p>You will be given a code to enter at <a href="https://accounts.x.ai/device" target="_blank" rel="noopener noreferrer">accounts.x.ai/device</a></p>
      </div>
    )
  }

  return (
    <div style={{ padding: '2rem', fontFamily: 'system-ui' }}>
      <h1>Authentication in Progress</h1>
      <p>Please complete the authentication in the popup window.</p>
    </div>
  )
}
