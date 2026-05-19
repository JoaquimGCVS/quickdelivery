import { Router } from 'express';
import { deliveriesController } from '../controllers/deliveries.controller';
import { authMiddleware } from '../middlewares/auth.middleware';

const router = Router();

router.post('/', authMiddleware, deliveriesController.create);
router.get('/', authMiddleware, deliveriesController.list);
router.get('/:id', authMiddleware, deliveriesController.findById);
router.patch('/:id/status', authMiddleware, deliveriesController.updateStatus);

export { router as deliveriesRoutes };
