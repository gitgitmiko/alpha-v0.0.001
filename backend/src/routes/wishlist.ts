import { Router } from 'express';

const router = Router();
const wishlistStore: unknown[] = [];
const favoritesStore: unknown[] = [];

router.get('/', (_, res) => res.json({ items: wishlistStore }));

router.post('/', (req, res) => {
  wishlistStore.push({ ...req.body, syncedAt: new Date().toISOString() });
  res.status(201).json({ ok: true });
});

router.post('/favorites', (req, res) => {
  favoritesStore.push(req.body);
  res.status(201).json({ ok: true });
});

export default router;
