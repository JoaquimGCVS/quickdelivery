import { NextFunction, Request, Response } from 'express';
import { deliveriesService } from '../services/deliveries.service';

export const deliveriesController = {
  async create(req: Request, res: Response, next: NextFunction) {
    try {
      const delivery = await deliveriesService.create(req.body);
      res.status(201).json(delivery);
    } catch (err) {
      next(err);
    }
  },
  async list(req: Request, res: Response, next: NextFunction) {
    try {
      const status = typeof req.query.status === 'string' ? req.query.status : undefined;
      const providerId =
        typeof req.query.providerId === 'string' ? req.query.providerId : undefined;
      const deliveries = await deliveriesService.list({ status, providerId });
      res.json(deliveries);
    } catch (err) {
      next(err);
    }
  },
  async findById(req: Request, res: Response, next: NextFunction) {
    try {
      const delivery = await deliveriesService.findById(req.params.id);
      res.json(delivery);
    } catch (err) {
      next(err);
    }
  },
  async updateStatus(req: Request, res: Response, next: NextFunction) {
    try {
      const delivery = await deliveriesService.updateStatus(req.params.id, req.body);
      res.json(delivery);
    } catch (err) {
      next(err);
    }
  },
};
