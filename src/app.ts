import express from 'express';
import { errorHandler } from './middlewares/error-handler';
import { apiRouter } from './routes';

export function createApp() {
  const app = express();
  app.use(express.json());
  app.get('/health', (_req, res) => {
    res.json({ status: 'ok' });
  });
  app.use('/', apiRouter);
  app.use(errorHandler);
  return app;
}
