import { NotFoundError } from '../middlewares/error-handler';
import { usersRepository } from '../repositories/users.repository';
import { USER_ROLES } from '../types/user';

export const deliverymenService = {
  async list() {
    return usersRepository.findMany(USER_ROLES.DELIVERYMAN);
  },

  async findById(id: string) {
    const deliveryman = await usersRepository.findById(id);
    if (!deliveryman || deliveryman.role !== USER_ROLES.DELIVERYMAN) {
      throw new NotFoundError(`Deliveryman ${id} not found`);
    }
    return deliveryman;
  },
};
