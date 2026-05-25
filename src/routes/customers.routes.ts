import { Router } from 'express';
import { customersController } from '../controllers/customers.controller';
import { authMiddleware, requireRole } from '../middlewares/auth.middleware';

const router = Router();

router.get('/', customersController.list);
router.get('/:id', customersController.findById);
router.delete('/:id', authMiddleware, requireRole('CUSTOMER'), customersController.delete);

export { router as customersRouter };
