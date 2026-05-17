import { Router } from 'express';
import {
  fetchProducts,
  fetchRecoIds,
  normalizeGame,
} from '../services/xboxApi';
import { cacheGet, cacheSet } from '../services/cache';

const router = Router();

router.get('/', async (req, res) => {
  try {
    const market = (req.query.market as string) ?? 'ID';
    const locale = (req.query.locale as string) ?? 'id-ID';
    const ids = ((req.query.ids as string) ?? '').split(',').filter(Boolean);
    if (!ids.length) {
      res.status(400).json({ error: 'ids required' });
      return;
    }
    const cacheKey = `products:${market}:${ids.join(',')}`;
    const cached = await cacheGet<unknown>(cacheKey);
    if (cached) {
      res.json(cached);
      return;
    }
    const data = (await fetchProducts(ids, market, `${locale},neutral`)) as {
      Products?: Record<string, unknown>[];
    };
    const games = (data.Products ?? []).map((p) => normalizeGame(p, market));
    await cacheSet(cacheKey, { Products: games });
    res.json({ Products: games });
  } catch (e) {
    res.status(502).json({ error: String(e) });
  }
});

router.get('/deals', async (req, res) => {
  try {
    const market = (req.query.market as string) ?? 'ID';
    const locale = (req.query.locale as string) ?? 'id-ID';
    const skip = Number(req.query.skip ?? 0);
    const count = Number(req.query.count ?? 25);
    const cacheKey = `deals:${market}:${skip}:${count}`;
    const cached = await cacheGet<unknown>(cacheKey);
    if (cached) {
      res.json(cached);
      return;
    }
    const ids = await fetchRecoIds('Deal', market, locale, skip, count);
    const data = (await fetchProducts(ids, market, `${locale},neutral`)) as {
      Products?: Record<string, unknown>[];
    };
    const games = (data.Products ?? []).map((p) => normalizeGame(p, market));
    const payload = { Products: games };
    await cacheSet(cacheKey, payload);
    res.json(payload);
  } catch (e) {
    res.status(502).json({ error: String(e) });
  }
});

router.get('/search', async (req, res) => {
  try {
    const market = (req.query.market as string) ?? 'ID';
    const locale = (req.query.locale as string) ?? 'id-ID';
    const q = ((req.query.q as string) ?? '').toLowerCase();
    const ids = await fetchRecoIds('Deal', market, locale, 0, 100);
    const data = (await fetchProducts(ids.slice(0, 40), market, `${locale},neutral`)) as {
      Products?: Record<string, unknown>[];
    };
    const games = (data.Products ?? [])
      .map((p) => normalizeGame(p, market))
      .filter((g) => g.title.toLowerCase().includes(q));
    res.json({ Products: games });
  } catch (e) {
    res.status(502).json({ error: String(e) });
  }
});

router.get('/compare/:id', async (req, res) => {
  const markets = ['ID', 'TR', 'AR', 'US', 'BR'];
  const regions = [];
  for (const market of markets) {
    try {
      const locale =
        market === 'ID'
          ? 'id-ID'
          : market === 'TR'
            ? 'tr-TR'
            : market === 'AR'
              ? 'es-AR'
              : market === 'BR'
                ? 'pt-BR'
                : 'en-US';
      const data = (await fetchProducts([req.params.id], market, `${locale},neutral`)) as {
        Products?: Record<string, unknown>[];
      };
      const game = data.Products?.[0];
      if (game) regions.push(normalizeGame(game, market));
    } catch {
      /* skip */
    }
  }
  res.json({ regions });
});

router.get('/history/:id', async (req, res) => {
  res.json({
    productId: req.params.id,
    history: [],
    message: 'Persist via Prisma in production deployment',
  });
});

router.get('/:id', async (req, res) => {
  try {
    const market = (req.query.market as string) ?? 'ID';
    const locale = (req.query.locale as string) ?? 'id-ID';
    const data = (await fetchProducts([req.params.id], market, `${locale},neutral`)) as {
      Products?: Record<string, unknown>[];
    };
    const game = data.Products?.[0];
    if (!game) {
      res.status(404).json({ error: 'Not found' });
      return;
    }
    res.json(normalizeGame(game, market));
  } catch (e) {
    res.status(502).json({ error: String(e) });
  }
});

export default router;
