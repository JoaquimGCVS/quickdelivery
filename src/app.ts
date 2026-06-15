import express from 'express';
import { errorHandler } from './middlewares/error-handler';
import { apiRouter } from './routes';

export function createApp() {
  const app = express();
  app.use((_req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Methods', 'GET,POST,PATCH,DELETE,OPTIONS');
    res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization');
    next();
  });
  app.options('*', (_req, res) => {
    res.sendStatus(204);
  });
  app.use(express.json());
  app.get('/health', (_req, res) => {
    res.json({ status: 'ok' });
  });
  app.use('/', apiRouter);
  app.use(errorHandler);
  return app;
}
