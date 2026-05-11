import { Router } from 'express';
import { providersController } from '../controllers/providers.controller';

const router = Router();

router.post('/', providersController.create);
router.get('/', providersController.list);

export { router as providersRoutes };
