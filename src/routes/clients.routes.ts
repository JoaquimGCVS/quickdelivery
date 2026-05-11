import { Router } from 'express';
import { clientsController } from '../controllers/clients.controller';

const router = Router();

router.post('/', clientsController.create);
router.get('/', clientsController.list);

export { router as clientsRoutes };
