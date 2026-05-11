import { ValidationError } from '../middlewares/error-handler';
import { clientsRepository } from '../repositories/clients.repository';

export const clientsService = {
  create(input: { name?: unknown; phone?: unknown }) {
    if (typeof input.name !== 'string' || !input.name.trim()) {
      throw new ValidationError('Field "name" is required');
    }
    if (typeof input.phone !== 'string' || !input.phone.trim()) {
      throw new ValidationError('Field "phone" is required');
    }
    return clientsRepository.create({ name: input.name.trim(), phone: input.phone.trim() });
  },
  list() {
    return clientsRepository.findAll();
  },
};
