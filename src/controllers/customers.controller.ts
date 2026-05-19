import { NextFunction, Request, Response } from 'express';
import { customersService } from '../services/customers.service';
import { ForbiddenError } from '../middlewares/error-handler';

export const customersController = {
  async list(req: Request, res: Response, next: NextFunction) {
    try {
      const customers = await customersService.list();
      res.json(customers);
    } catch (err) {
      next(err);
    }
  },

  async findById(req: Request, res: Response, next: NextFunction) {
    try {
      const customer = await customersService.findById(req.params.id);
      res.json(customer);
    } catch (err) {
      next(err);
    }
  },

  async delete(req: Request, res: Response, next: NextFunction) {
    try {
      const user = (req as any).user;
      if (user.userId !== req.params.id) {
        throw new ForbiddenError('You can only delete your own account');
      }
      await customersService.delete(req.params.id);
      res.status(204).send();
    } catch (err) {
      next(err);
    }
  },
};
