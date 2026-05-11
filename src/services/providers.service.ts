import { ValidationError } from '../middlewares/error-handler';
import { providersRepository } from '../repositories/providers.repository';

export const providersService = {
  create(input: { name?: unknown; phone?: unknown }) {
    if (typeof input.name !== 'string' || !input.name.trim()) {
      throw new ValidationError('Field "name" is required');
    }
    if (typeof input.phone !== 'string' || !input.phone.trim()) {
      throw new ValidationError('Field "phone" is required');
    }
    return providersRepository.create({ name: input.name.trim(), phone: input.phone.trim() });
  },
  list() {
    return providersRepository.findAll();
  },
};
