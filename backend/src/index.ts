import cors from 'cors';
import dotenv from 'dotenv';
import express from 'express';
import helmet from 'helmet';
import morgan from 'morgan';

import { apiKeyMiddleware } from './middleware/apiKey';
import { rateLimiter } from './middleware/rateLimit';
import { registerCronJobs } from './jobs/cron';
import gamesRouter from './routes/games';
import gamepassRouter from './routes/gamepass';
import regionsRouter from './routes/regions';
import wishlistRouter from './routes/wishlist';
import compareRouter from './routes/compare';

dotenv.config();

const app = express();
const port = process.env.PORT ?? 3000;

app.use(helmet());
app.use(cors());
app.use(morgan('combined'));
app.use(express.json());
app.use(rateLimiter);
app.use(apiKeyMiddleware);

app.get('/health', (_, res) => res.json({ status: 'ok' }));

app.use('/games', gamesRouter);
app.use('/gamepass', gamepassRouter);
app.use('/regions', regionsRouter);
app.use('/wishlist', wishlistRouter);
app.use('/favorites', wishlistRouter);
app.use('/compare', compareRouter);

registerCronJobs();

app.listen(port, () => {
  console.log(`Xbox Region Store API listening on :${port}`);
});
