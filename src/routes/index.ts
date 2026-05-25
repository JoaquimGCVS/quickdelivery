import { Router } from 'express';
import { authRouter } from './auth.routes';
import { customersRouter } from './customers.routes';
import { deliverymenRouter } from './deliverymen.routes';
import { deliveriesRoutes } from './deliveries.routes';

const router = Router();

router.use('/auth', authRouter);
router.use('/customers', customersRouter);
router.use('/deliverymen', deliverymenRouter);
router.use('/deliveries', deliveriesRoutes);

export { router as apiRouter };
