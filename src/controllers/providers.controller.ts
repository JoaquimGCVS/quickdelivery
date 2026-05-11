import { NextFunction, Request, Response } from 'express';
import { providersService } from '../services/providers.service';

export const providersController = {
  async create(req: Request, res: Response, next: NextFunction) {
    try {
      const provider = await providersService.create(req.body);
      res.status(201).json(provider);
    } catch (err) {
      next(err);
    }
  },
  async list(_req: Request, res: Response, next: NextFunction) {
    try {
      const providers = await providersService.list();
      res.json(providers);
    } catch (err) {
      next(err);
    }
  },
};
