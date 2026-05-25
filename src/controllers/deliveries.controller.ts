import { NextFunction, Request, Response } from 'express';
import { deliveriesService } from '../services/deliveries.service';

export const deliveriesController = {
  async create(req: Request, res: Response, next: NextFunction) {
    try {
      const user = (req as any).user;
      const delivery = await deliveriesService.create(req.body, user.userId);
      res.status(201).json(delivery);
    } catch (err) {
      next(err);
    }
  },
  async list(req: Request, res: Response, next: NextFunction) {
    try {
      const user = (req as any).user;
      const status = typeof req.query.status === 'string' ? req.query.status : undefined;
      const deliverymanId =
        typeof req.query.deliverymanId === 'string' ? req.query.deliverymanId : undefined;
      const deliveries = await deliveriesService.list({ status, deliverymanId }, user.userId, user.role);
      res.json(deliveries);
    } catch (err) {
      next(err);
    }
  },
  async findById(req: Request, res: Response, next: NextFunction) {
    try {
      const user = (req as any).user;
      const delivery = await deliveriesService.findById(req.params.id, user.userId, user.role);
      res.json(delivery);
    } catch (err) {
      next(err);
    }
  },
  async updateStatus(req: Request, res: Response, next: NextFunction) {
    try {
      const user = (req as any).user;
      const delivery = await deliveriesService.updateStatus(req.params.id, req.body, user.userId, user.role);
      res.json(delivery);
    } catch (err) {
      next(err);
    }
  },
};
