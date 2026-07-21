// web-app/tests/api/auth/grok-device.test.ts
import { describe, it, expect, beforeEach, afterEach } from '@jest/globals';
import { createMocks } from 'node-mocks-http';
import handler from '../../../pages/api/auth/grok-device';

describe('/api/auth/grok-device', () => {
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
      body: {},
    });

    await handler(req, res);

    expect(res._getStatusCode()).toBe(400);
    expect(JSON.parse(res._getData())).toEqual({
      error: 'Missing userId',
    });
  });

  it('should request device code successfully', async () => {
    const mockDeviceData = {
      device_code: 'test-device-code',
      user_code: 'ABCD-1234',
      verification_uri: 'https://accounts.x.ai/device',
      expires_in: 600,
      interval: 5,
    };

    const originalFetch = global.fetch;
    global.fetch = jest.fn(() =>
      Promise.resolve({
        ok: true,
        json: () => Promise.resolve(mockDeviceData),
      })
    ) as any;

    const { req, res } = createMocks({
      method: 'POST',
      body: {
        userId: '12345',
      },
    });

    await handler(req, res);

    expect(res._getStatusCode()).toBe(200);
    const data = JSON.parse(res._getData());
    expect(data.success).toBe(true);
    expect(data.userId).toBe('12345');
    expect(data.provider).toBe('grok');
    expect(data.deviceCode).toBe('test-device-code');
    expect(data.userCode).toBe('ABCD-1234');
    expect(data.verificationUri).toBe('https://accounts.x.ai/device');
    expect(data.expiresIn).toBe(600);
    expect(data.interval).toBe(5);

    global.fetch = originalFetch;
  });

  it('should return 500 if device code request fails', async () => {
    const originalFetch = global.fetch;
    global.fetch = jest.fn(() =>
      Promise.resolve({
        ok: false,
        text: () => Promise.resolve('Invalid client'),
      })
    ) as any;

    const { req, res } = createMocks({
      method: 'POST',
      body: {
        userId: '12345',
      },
    });

    await handler(req, res);

    expect(res._getStatusCode()).toBe(500);
    expect(JSON.parse(res._getData())).toEqual({
      error: 'Failed to request device code',
    });

    global.fetch = originalFetch;
  });
});
