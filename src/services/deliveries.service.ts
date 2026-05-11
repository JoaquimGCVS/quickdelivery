import { NotFoundError, ValidationError } from '../middlewares/error-handler';
import { clientsRepository } from '../repositories/clients.repository';
import { deliveriesRepository } from '../repositories/deliveries.repository';
import { providersRepository } from '../repositories/providers.repository';
import { DeliveryStatus, canTransition, isDeliveryStatus } from '../types/delivery-status';

function requireString(value: unknown, field: string): string {
  if (typeof value !== 'string' || !value.trim()) {
    throw new ValidationError(`Field "${field}" is required`);
  }
  return value.trim();
}

function parseStatus(raw: string, field = 'status'): DeliveryStatus {
  const upper = raw.toUpperCase();
  if (!isDeliveryStatus(upper)) {
    throw new ValidationError(`Invalid value for "${field}": "${raw}"`);
  }
  return upper;
}

export const deliveriesService = {
  async create(input: {
    clientId?: unknown;
    pickupAddress?: unknown;
    dropoffAddress?: unknown;
    description?: unknown;
  }) {
    const clientId = requireString(input.clientId, 'clientId');
    const pickupAddress = requireString(input.pickupAddress, 'pickupAddress');
    const dropoffAddress = requireString(input.dropoffAddress, 'dropoffAddress');
    const description = requireString(input.description, 'description');

    const client = await clientsRepository.findById(clientId);
    if (!client) throw new NotFoundError(`Client ${clientId} not found`);

    return deliveriesRepository.create({ clientId, pickupAddress, dropoffAddress, description });
  },

  async findById(id: string) {
    const delivery = await deliveriesRepository.findById(id);
    if (!delivery) throw new NotFoundError(`Delivery ${id} not found`);
    return delivery;
  },

  list(filters: { status?: string; providerId?: string }) {
    const status = filters.status ? parseStatus(filters.status) : undefined;
    return deliveriesRepository.findMany({ status, providerId: filters.providerId });
  },

  async updateStatus(id: string, input: { status?: unknown; providerId?: unknown }) {
    const rawStatus = requireString(input.status, 'status');
    const nextStatus = parseStatus(rawStatus);

    const delivery = await deliveriesRepository.findById(id);
    if (!delivery) throw new NotFoundError(`Delivery ${id} not found`);

    if (!canTransition(delivery.status, nextStatus)) {
      throw new ValidationError(
        `Invalid transition from ${delivery.status} to ${nextStatus}`,
      );
    }

    let providerId: string | undefined;
    if (nextStatus === 'ACCEPTED') {
      providerId = requireString(input.providerId, 'providerId');
      const provider = await providersRepository.findById(providerId);
      if (!provider) throw new NotFoundError(`Provider ${providerId} not found`);
    }

    return deliveriesRepository.updateStatus(id, nextStatus, providerId);
  },
};
