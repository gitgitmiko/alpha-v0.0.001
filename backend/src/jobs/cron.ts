import cron from 'node-cron';
import { fetchRecoIds, fetchProducts } from '../services/xboxApi';
import { cacheSet } from '../services/cache';

const MARKETS = ['ID', 'TR', 'US'];

export function registerCronJobs(): void {
  cron.schedule('0 * * * *', async () => {
    console.log('[cron] Refreshing game prices...');
    for (const market of MARKETS) {
      try {
        const locale = market === 'ID' ? 'id-ID' : market === 'TR' ? 'tr-TR' : 'en-US';
        const ids = await fetchRecoIds('Deal', market, locale, 0, 50);
        const data = await fetchProducts(ids, market, `${locale},neutral`);
        await cacheSet(`cron:deals:${market}`, data, 3600);
      } catch (e) {
        console.error(`[cron] Failed for ${market}`, e);
      }
    }
    console.log('[cron] Done');
  });
}
