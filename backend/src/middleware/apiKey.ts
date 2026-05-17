import { Request, Response, NextFunction } from 'express';

export function apiKeyMiddleware(
  req: Request,
  res: Response,
  next: NextFunction,
): void {
  const required = process.env.API_KEY;
  if (!required) {
    next();
    return;
  }
  const key = req.header('X-API-Key');
  if (key !== required) {
    res.status(401).json({ error: 'Invalid API key' });
    return;
  }
  next();
}
