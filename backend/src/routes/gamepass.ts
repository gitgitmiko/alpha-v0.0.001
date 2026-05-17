import { Router } from 'express';
import { fetchProducts, fetchRecoIds, normalizeGame } from '../services/xboxApi';
import { cacheGet, cacheSet } from '../services/cache';

const GP_SKUS = [
  { id: 'CFQ7TTC0KGQ8', name: 'PC Game Pass' },
  { id: 'CFQ7TTC0K5DJ', name: 'Game Pass Core' },
  { id: 'CFQ7TTC0P85B', name: 'Game Pass Standard' },
  { id: 'CFQ7TTC0KHS0', name: 'Game Pass Ultimate' },
];

const router = Router();

router.get('/', async (req, res) => {
  try {
    const market = (req.query.market as string) ?? 'ID';
    const locale = (req.query.locale as string) ?? 'id-ID';
    const cacheKey = `gamepass:${market}`;
    const cached = await cacheGet<string[]>(cacheKey);
    if (cached) {
      res.json({ ids: cached });
      return;
    }
    const ids = await fetchRecoIds('TopFree', market, locale, 0, 50);
    await cacheSet(cacheKey, ids);
    res.json({ ids });
  } catch (e) {
    res.status(502).json({ error: String(e) });
  }
});

router.get('/prices', async (req, res) => {
  try {
    const market = (req.query.market as string) ?? 'ID';
    const locale = (req.query.locale as string) ?? 'id-ID';
    const ids = GP_SKUS.map((s) => s.id);
    const data = (await fetchProducts(ids, market, `${locale},neutral`)) as {
      Products?: Record<string, unknown>[];
    };
    const products = data.Products ?? [];
    const prices = GP_SKUS.map((sku) => {
      const product = products.find((p) => p.ProductId === sku.id);
      const normalized = product
        ? normalizeGame(product, market)
        : {
            productId: sku.id,
            title: sku.name,
            discountedPrice: 0,
            currency: 'USD',
          };
      return {
        skuId: sku.id,
        name: sku.name,
        price: normalized.discountedPrice,
        currency: normalized.currency,
        region: market,
      };
    });
    res.json({ prices });
  } catch (e) {
    res.status(502).json({ error: String(e) });
  }
});

export default router;
