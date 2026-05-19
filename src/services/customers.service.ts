import { NotFoundError } from '../middlewares/error-handler';
import { usersRepository } from '../repositories/users.repository';
import { USER_ROLES } from '../types/user';

export const customersService = {
  async list() {
    return usersRepository.findMany(USER_ROLES.CUSTOMER);
  },

  async findById(id: string) {
    const customer = await usersRepository.findById(id);
    if (!customer || customer.role !== USER_ROLES.CUSTOMER) {
      throw new NotFoundError(`Customer ${id} not found`);
    }
    return customer;
  },

  async delete(id: string) {
    return usersRepository.delete(id);
  },
};
