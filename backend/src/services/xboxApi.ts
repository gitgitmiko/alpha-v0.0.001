import axios from 'axios';

const DISPLAY_CATALOG = 'https://displaycatalog.mp.microsoft.com';
const RECO = 'https://reco-public.rec.mp.microsoft.com';

export const RECO_LISTS: Record<string, string> = {
  Deal: 'Computed/Deal',
  New: 'Computed/New',
  TopPaid: 'Computed/TopPaid',
};

export async function fetchRecoIds(
  list: string,
  market: string,
  language: string,
  skip = 0,
  count = 25,
): Promise<string[]> {
  const path = RECO_LISTS[list] ?? RECO_LISTS.Deal;
  const url = `${RECO}/channels/Reco/V8.0/Lists/${path}`;
  const { data } = await axios.get(url, {
    params: {
      market: market.toLowerCase(),
      language,
      itemTypes: 'Game',
      deviceFamily: 'Windows.Xbox',
      count,
      skipItems: skip,
    },
    timeout: 20000,
  });
  const items = data.Items ?? [];
  return items
    .map((item: { Id?: string; Item?: { Id?: string } }) =>
      item.Id ?? item.Item?.Id,
    )
    .filter(Boolean) as string[];
}

export async function fetchProducts(
  bigIds: string[],
  market: string,
  languages: string,
): Promise<unknown> {
  const { data } = await axios.get(`${DISPLAY_CATALOG}/v7.0/products`, {
    params: { bigIds: bigIds.join(','), market, languages },
    timeout: 20000,
  });
  return data;
}

export function normalizeGame(product: Record<string, unknown>, market: string) {
  const localized = (product.LocalizedProperties as Record<string, unknown>[])?.[0];
  const title = (localized?.ProductTitle as string) ?? product.ProductId;
  const images = (localized?.Images as Record<string, unknown>[]) ?? [];
  const imageUri =
    images.find((i) => i.ImagePurpose === 'Poster')?.Uri ??
    images[0]?.Uri ??
    '';

  const skuAvail = (product.DisplaySkuAvailabilities as Record<string, unknown>[]) ?? [];
  let originalPrice = 0;
  let discountedPrice = 0;
  let currency = 'USD';
  let discountPercent = 0;

  for (const sku of skuAvail) {
    const avails = (sku.Availabilities as Record<string, unknown>[]) ?? [];
    for (const av of avails) {
      const actions = (av.Actions as string[]) ?? [];
      if (!actions.includes('Purchase')) continue;
      const price = (av.OrderManagementData as Record<string, unknown>)
        ?.Price as Record<string, number | string>;
      if (!price) continue;
      const list = Number(price.ListPrice ?? 0);
      const msrp = Number(price.MSRP ?? list);
      currency = (price.CurrencyCode as string) ?? currency;
      if (list > 0) {
        originalPrice = msrp || list;
        discountedPrice = list;
        if (originalPrice > discountedPrice) {
          discountPercent = ((originalPrice - discountedPrice) / originalPrice) * 100;
        }
        break;
      }
    }
  }

  return {
    productId: product.ProductId,
    title,
    imageUrl: imageUri?.toString().startsWith('http')
      ? imageUri
      : `https:${imageUri}`,
    originalPrice,
    discountedPrice,
    currency,
    discountPercent,
    region: market,
  };
}
