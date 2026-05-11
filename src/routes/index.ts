import { Router } from 'express';
import { clientsRoutes } from './clients.routes';
import { deliveriesRoutes } from './deliveries.routes';
import { providersRoutes } from './providers.routes';

const router = Router();

router.use('/clients', clientsRoutes);
router.use('/providers', providersRoutes);
router.use('/deliveries', deliveriesRoutes);

export { router as apiRouter };
