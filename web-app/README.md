# ManaJar Web App

OAuth callback server for LLM provider authentication.

## Setup

1. Install dependencies:
```bash
npm install
```

2. Configure environment variables:
```bash
cp .env.example .env.local
```

Edit `.env.local` with your OAuth credentials:
- `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET` from Google Cloud Console
- `XAI_CLIENT_ID` from xAI Developer Console
- `NEXT_PUBLIC_APP_URL` = `https://manajar.app`

3. Run locally:
```bash
npm run dev
```

## Deploy to Vercel

1. Push to GitHub
2. Connect repo to Vercel
3. Add environment variables in Vercel dashboard
4. Deploy

## OAuth Flows

### Google Gemini (Authorization Code)

1. User visits `https://manajar.app/auth?userId={userId}&provider=gemini`
2. Redirected to Google OAuth
3. After auth, redirected to `/api/auth/gemini?code={code}&state={userId}`
4. Web app exchanges code for tokens
5. Returns tokens (in production, store in database)

### xAI Grok (Device Code)

1. Roblox server calls `/api/auth/grok-device` with userId
2. Web app requests device code from xAI
3. Returns device code, user code, verification URI
4. User visits `https://accounts.x.ai/device` and enters code
5. Roblox server polls `/api/auth/grok-poll` with device code
6. When user completes auth, returns tokens

## API Endpoints

- `GET /auth` - OAuth entry point
- `POST /api/auth/grok-device` - Request Grok device code
- `POST /api/auth/grok-poll` - Poll for Grok token
- `GET /api/auth/gemini` - Gemini OAuth callback
