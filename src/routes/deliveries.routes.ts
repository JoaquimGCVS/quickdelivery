import { Router } from 'express';
import { deliveriesController } from '../controllers/deliveries.controller';

const router = Router();

router.post('/', deliveriesController.create);
router.get('/', deliveriesController.list);
router.get('/:id', deliveriesController.findById);
router.patch('/:id/status', deliveriesController.updateStatus);

export { router as deliveriesRoutes };
