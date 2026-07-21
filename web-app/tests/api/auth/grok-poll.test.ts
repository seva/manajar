// web-app/tests/api/auth/grok-poll.test.ts
import { describe, it, expect, beforeEach, afterEach } from '@jest/globals';
import { createMocks } from 'node-mocks-http';
import handler from '../../../pages/api/auth/grok-poll';

describe('/api/auth/grok-poll', () => {
  beforeEach(() => {
    process.env.XAI_CLIENT_ID = 'test-xai-client-id';
  });

  afterEach(() => {
    delete process.env.XAI_CLIENT_ID;
  });

  it('should return 405 for non-POST requests', async () => {
    const { req, res } = createMocks({
      method: 'GET',
    });

    await handler(req, res);

    expect(res._getStatusCode()).toBe(405);
    expect(JSON.parse(res._getData())).toEqual({
      error: 'Method not allowed',
    });
  });

  it('should return 400 if userId is missing', async () => {
    const { req, res } = createMocks({
      method: 'POST',
      body: {
        deviceCode: 'test-device-code',
      },
    });

    await handler(req, res);

    expect(res._getStatusCode()).toBe(400);
    expect(JSON.parse(res._getData())).toEqual({
      error: 'Missing userId or deviceCode',
    });
  });

  it('should return 400 if deviceCode is missing', async () => {
    const { req, res } = createMocks({
      method: 'POST',
      body: {
        userId: '12345',
      },
    });

    await handler(req, res);

    expect(res._getStatusCode()).toBe(400);
    expect(JSON.parse(res._getData())).toEqual({
      error: 'Missing userId or deviceCode',
    });
  });

  it('should return pending status when authorization is pending', async () => {
    const originalFetch = global.fetch;
    global.fetch = jest.fn(() =>
      Promise.resolve({
        ok: false,
        json: () =>
          Promise.resolve({
            error: 'authorization_pending',
          }),
      })
    ) as any;

    const { req, res } = createMocks({
      method: 'POST',
      body: {
        userId: '12345',
        deviceCode: 'test-device-code',
      },
    });

    await handler(req, res);

    expect(res._getStatusCode()).toBe(200);
    const data = JSON.parse(res._getData());
    expect(data.success).toBe(false);
    expect(data.status).toBe('pending');
    expect(data.message).toBe('Authorization pending');

    global.fetch = originalFetch;
  });

  it('should return slow_down status when polling too fast', async () => {
    const originalFetch = global.fetch;
    global.fetch = jest.fn(() =>
      Promise.resolve({
        ok: false,
        json: () =>
          Promise.resolve({
            error: 'slow_down',
          }),
      })
    ) as any;

    const { req, res } = createMocks({
      method: 'POST',
      body: {
        userId: '12345',
        deviceCode: 'test-device-code',
      },
    });

    await handler(req, res);

    expect(res._getStatusCode()).toBe(200);
    const data = JSON.parse(res._getData());
    expect(data.success).toBe(false);
    expect(data.status).toBe('slow_down');
    expect(data.message).toBe('Please slow down polling');

    global.fetch = originalFetch;
  });

  it('should return expired status when device code expired', async () => {
    const originalFetch = global.fetch;
    global.fetch = jest.fn(() =>
      Promise.resolve({
        ok: false,
        json: () =>
          Promise.resolve({
            error: 'expired_token',
          }),
      })
    ) as any;

    const { req, res } = createMocks({
      method: 'POST',
      body: {
        userId: '12345',
        deviceCode: 'test-device-code',
      },
    });

    await handler(req, res);

    expect(res._getStatusCode()).toBe(200);
    const data = JSON.parse(res._getData());
    expect(data.success).toBe(false);
    expect(data.status).toBe('expired');
    expect(data.message).toBe('Device code expired');

    global.fetch = originalFetch;
  });

  it('should return denied status when access denied', async () => {
    const originalFetch = global.fetch;
    global.fetch = jest.fn(() =>
      Promise.resolve({
        ok: false,
        json: () =>
          Promise.resolve({
            error: 'access_denied',
          }),
      })
    ) as any;

    const { req, res } = createMocks({
      method: 'POST',
      body: {
        userId: '12345',
        deviceCode: 'test-device-code',
      },
    });

    await handler(req, res);

    expect(res._getStatusCode()).toBe(200);
    const data = JSON.parse(res._getData());
    expect(data.success).toBe(false);
    expect(data.status).toBe('denied');
    expect(data.message).toBe('Access denied');

    global.fetch = originalFetch;
  });

  it('should return tokens successfully when authorized', async () => {
    const mockTokenData = {
      access_token: 'test-access-token',
      refresh_token: 'test-refresh-token',
      expires_in: 3600,
    };

    const originalFetch = global.fetch;
    global.fetch = jest.fn(() =>
      Promise.resolve({
        ok: true,
        json: () => Promise.resolve(mockTokenData),
      })
    ) as any;

    const { req, res } = createMocks({
      method: 'POST',
      body: {
        userId: '12345',
        deviceCode: 'test-device-code',
      },
    });

    await handler(req, res);

    expect(res._getStatusCode()).toBe(200);
    const data = JSON.parse(res._getData());
    expect(data.success).toBe(true);
    expect(data.userId).toBe('12345');
    expect(data.provider).toBe('grok');
    expect(data.accessToken).toBe('test-access-token');
    expect(data.refreshToken).toBe('test-refresh-token');
    expect(data.expiresAt).toBeGreaterThan(Date.now());

    global.fetch = originalFetch;
  });

  it('should return 500 if token poll fails with unexpected error', async () => {
    const originalFetch = global.fetch;
    global.fetch = jest.fn(() =>
      Promise.resolve({
        ok: false,
        json: () =>
          Promise.resolve({
            error: 'server_error',
            error_description: 'Internal server error',
          }),
      })
    ) as any;

    const { req, res } = createMocks({
      method: 'POST',
      body: {
        userId: '12345',
        deviceCode: 'test-device-code',
      },
    });

    await handler(req, res);

    expect(res._getStatusCode()).toBe(500);
    expect(JSON.parse(res._getData())).toEqual({
      error: 'Failed to poll for token',
    });

    global.fetch = originalFetch;
  });
});
