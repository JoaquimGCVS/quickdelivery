import { NextFunction, Request, Response } from 'express';
import { clientsService } from '../services/clients.service';

export const clientsController = {
  async create(req: Request, res: Response, next: NextFunction) {
    try {
      const client = await clientsService.create(req.body);
      res.status(201).json(client);
    } catch (err) {
      next(err);
    }
  },
  async list(_req: Request, res: Response, next: NextFunction) {
    try {
      const clients = await clientsService.list();
      res.json(clients);
    } catch (err) {
      next(err);
    }
  },
};
