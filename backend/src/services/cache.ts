import Redis from 'ioredis';

const redisUrl = process.env.REDIS_URL ?? 'redis://localhost:6379';
let redis: Redis | null = null;

export function getRedis(): Redis | null {
  if (process.env.REDIS_ENABLED !== 'true') return null;
  if (!redis) {
    redis = new Redis(redisUrl, { maxRetriesPerRequest: 2 });
  }
  return redis;
}

const memoryCache = new Map<string, { data: string; expires: number }>();

export async function cacheGet<T>(key: string): Promise<T | null> {
  const r = getRedis();
  if (r) {
    const val = await r.get(key);
    return val ? (JSON.parse(val) as T) : null;
  }
  const entry = memoryCache.get(key);
  if (!entry || Date.now() > entry.expires) return null;
  return JSON.parse(entry.data) as T;
}

export async function cacheSet(
  key: string,
  value: unknown,
  ttlSeconds = 3600,
): Promise<void> {
  const serialized = JSON.stringify(value);
  const r = getRedis();
  if (r) {
    await r.setex(key, ttlSeconds, serialized);
    return;
  }
  memoryCache.set(key, {
    data: serialized,
    expires: Date.now() + ttlSeconds * 1000,
  });
}
