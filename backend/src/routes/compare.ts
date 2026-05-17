import { Router } from 'express';
import { fetchProducts, normalizeGame } from '../services/xboxApi';

const router = Router();

router.get('/:id', async (req, res) => {
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

export default router;
