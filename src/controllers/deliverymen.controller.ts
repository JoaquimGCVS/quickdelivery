import { NextFunction, Request, Response } from 'express';
import { deliverymenService } from '../services/deliverymen.service';

export const deliverymenController = {
  async list(req: Request, res: Response, next: NextFunction) {
    try {
      const deliverymen = await deliverymenService.list();
      res.json(deliverymen);
    } catch (err) {
      next(err);
    }
  },

  async findById(req: Request, res: Response, next: NextFunction) {
    try {
      const deliveryman = await deliverymenService.findById(req.params.id);
      res.json(deliveryman);
    } catch (err) {
      next(err);
    }
  },
};
