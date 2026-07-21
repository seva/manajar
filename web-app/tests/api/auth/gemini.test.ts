// web-app/tests/api/auth/gemini.test.ts
import { describe, it, expect, beforeEach, afterEach } from '@jest/globals';
import { createMocks } from 'node-mocks-http';
import handler from '../../../pages/api/auth/gemini';

describe('/api/auth/gemini', () => {
  beforeEach(() => {
    // Reset environment variables
    process.env.GOOGLE_CLIENT_ID = 'test-client-id';
    process.env.GOOGLE_CLIENT_SECRET = 'test-client-secret';
    process.env.NEXT_PUBLIC_APP_URL = 'http://localhost:3000';
  });

  afterEach(() => {
    delete process.env.GOOGLE_CLIENT_ID;
    delete process.env.GOOGLE_CLIENT_SECRET;
    delete process.env.NEXT_PUBLIC_APP_URL;
  });

  it('should return 400 if code is missing', async () => {
    const { req, res } = createMocks({
      method: 'GET',
      query: {
        state: '12345',
      },
    });

    await handler(req, res);

    expect(res._getStatusCode()).toBe(400);
    expect(JSON.parse(res._getData())).toEqual({
      error: 'Missing code or state parameter',
    });
  });

  it('should return 400 if state is missing', async () => {
    const { req, res } = createMocks({
      method: 'GET',
      query: {
        code: 'test-code',
      },
    });

    await handler(req, res);

    expect(res._getStatusCode()).toBe(400);
    expect(JSON.parse(res._getData())).toEqual({
      error: 'Missing code or state parameter',
    });
  });

  it('should exchange code for tokens successfully', async () => {
    // Mock fetch
    const originalFetch = global.fetch;
    global.fetch = jest.fn(() =>
      Promise.resolve({
        ok: true,
        json: () =>
          Promise.resolve({
            access_token: 'test-access-token',
            refresh_token: 'test-refresh-token',
            expires_in: 3600,
          }),
      })
    ) as any;

    const { req, res } = createMocks({
      method: 'GET',
      query: {
        code: 'test-code',
        state: '12345',
      },
    });

    await handler(req, res);

    expect(res._getStatusCode()).toBe(200);
    const data = JSON.parse(res._getData());
    expect(data.success).toBe(true);
    expect(data.userId).toBe('12345');
    expect(data.provider).toBe('gemini');
    expect(data.accessToken).toBe('test-access-token');
    expect(data.refreshToken).toBe('test-refresh-token');
    expect(data.expiresAt).toBeGreaterThan(Date.now());

    global.fetch = originalFetch;
  });

  it('should return 500 if token exchange fails', async () => {
    // Mock fetch to fail
    const originalFetch = global.fetch;
    global.fetch = jest.fn(() =>
      Promise.resolve({
        ok: false,
        text: () => Promise.resolve('Invalid code'),
      })
    ) as any;

    const { req, res } = createMocks({
      method: 'GET',
      query: {
        code: 'invalid-code',
        state: '12345',
      },
    });

    await handler(req, res);

    expect(res._getStatusCode()).toBe(500);
    expect(JSON.parse(res._getData())).toEqual({
      error: 'Failed to exchange code for tokens',
    });

    global.fetch = originalFetch;
  });
});
