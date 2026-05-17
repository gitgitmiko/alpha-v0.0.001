import { Router } from 'express';

const router = Router();

const REGIONS = [
  { market: 'ID', locale: 'id-ID', name: 'Indonesia', currency: 'IDR' },
  { market: 'TR', locale: 'tr-TR', name: 'Turkey', currency: 'TRY' },
  { market: 'AR', locale: 'es-AR', name: 'Argentina', currency: 'ARS' },
  { market: 'US', locale: 'en-US', name: 'United States', currency: 'USD' },
  { market: 'BR', locale: 'pt-BR', name: 'Brazil', currency: 'BRL' },
];

router.get('/', (_, res) => res.json({ regions: REGIONS }));

export default router;
