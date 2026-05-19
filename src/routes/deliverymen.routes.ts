import { Router } from 'express';
import { deliverymenController } from '../controllers/deliverymen.controller';

const router = Router();

router.get('/', deliverymenController.list);
router.get('/:id', deliverymenController.findById);

export { router as deliverymenRouter };
