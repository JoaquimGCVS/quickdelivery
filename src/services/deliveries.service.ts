import { NotFoundError, ValidationError, ForbiddenError } from '../middlewares/error-handler';
import { usersRepository } from '../repositories/users.repository';
import { deliveriesRepository } from '../repositories/deliveries.repository';
import { DeliveryStatus, canTransition, isDeliveryStatus } from '../types/delivery-status';
import { prismaClient } from '../infrastructure/prisma';

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
    customerId?: unknown;
    pickupAddress?: unknown;
    dropoffAddress?: unknown;
    description?: unknown;
  }, authenticatedUserId: string) {
    const customerId = requireString(input.customerId, 'customerId');
    const pickupAddress = requireString(input.pickupAddress, 'pickupAddress');
    const dropoffAddress = requireString(input.dropoffAddress, 'dropoffAddress');
    const description = requireString(input.description, 'description');

    if (customerId !== authenticatedUserId) {
      throw new ForbiddenError('You can only create deliveries for yourself');
    }

    const customer = await usersRepository.findById(customerId);
    if (!customer) throw new NotFoundError(`Customer ${customerId} not found`);
    if (customer.role !== 'CUSTOMER') throw new ValidationError('Customer must be a CUSTOMER');

    const delivery = await deliveriesRepository.create({ customerId, pickupAddress, dropoffAddress, description });
    return delivery;
  },

  async findById(id: string, authenticatedUserId: string, userRole: string) {
    const delivery = await deliveriesRepository.findById(id);
    if (!delivery) throw new NotFoundError(`Delivery ${id} not found`);

    if (userRole === 'CUSTOMER' && delivery.customerId !== authenticatedUserId) {
      throw new ForbiddenError('You can only view your own deliveries');
    }

    if (
      userRole === 'DELIVERYMAN' &&
      delivery.status !== 'PENDING' &&
      delivery.deliverymanId !== authenticatedUserId
    ) {
      throw new ForbiddenError('You can only view pending deliveries or deliveries assigned to you');
    }

    return delivery;
  },

  async list(filters: { status?: string; deliverymanId?: string }, authenticatedUserId: string, userRole: string) {
    const status = filters.status ? parseStatus(filters.status) : undefined;

    // Se for CUSTOMER, só pode ver seus próprios pedidos
    if (userRole === 'CUSTOMER') {
      return deliveriesRepository.findMany({ status, customerId: authenticatedUserId });
    }

    // Se for DELIVERYMAN, vê entregas PENDING (disponíveis) + as que ele aceitou
    if (userRole === 'DELIVERYMAN') {
      // Se filtrou por status específico, respeita o filtro
      if (status) {
        if (status === 'PENDING') {
          // Ver apenas PENDING
          return prismaClient.delivery.findMany({
            where: { status: 'PENDING' },
            orderBy: { createdAt: 'desc' },
          });
        } else {
          // Ver status específico apenas de suas entregas aceitas
          return deliveriesRepository.findMany({ status, deliverymanId: authenticatedUserId });
        }
      }
      // Sem filtro: vê PENDING + suas entregas aceitas
      return prismaClient.delivery.findMany({
        where: {
          OR: [
            { status: 'PENDING' },
            { deliverymanId: authenticatedUserId },
          ],
        },
        orderBy: { createdAt: 'desc' },
      });
    }

    return [];
  },

  async updateStatus(
    id: string,
    input: { status?: unknown; deliverymanId?: unknown },
    authenticatedUserId: string,
    userRole: string,
  ) {
    const rawStatus = requireString(input.status, 'status');
    const nextStatus = parseStatus(rawStatus);

    const delivery = await deliveriesRepository.findById(id);
    if (!delivery) throw new NotFoundError(`Delivery ${id} not found`);

    if (!canTransition(delivery.status, nextStatus)) {
      throw new ValidationError(
        `Invalid transition from ${delivery.status} to ${nextStatus}`,
      );
    }

    // Validações de autorização
    if (userRole === 'CUSTOMER' && delivery.customerId !== authenticatedUserId) {
      throw new ForbiddenError('You can only modify your own deliveries');
    }

    if (userRole === 'DELIVERYMAN' && delivery.deliverymanId && delivery.deliverymanId !== authenticatedUserId) {
      throw new ForbiddenError('You can only modify deliveries assigned to you');
    }

    // Se tentando aceitar um pedido, deliverymanId é obrigatório
    let deliverymanId: string | undefined;
    if (nextStatus === 'ACCEPTED') {
      deliverymanId = requireString(input.deliverymanId, 'deliverymanId');
      if (userRole === 'DELIVERYMAN' && deliverymanId !== authenticatedUserId) {
        throw new ForbiddenError('You can only accept deliveries for yourself');
      }
      const deliveryman = await usersRepository.findById(deliverymanId);
      if (!deliveryman) throw new NotFoundError(`Deliveryman ${deliverymanId} not found`);
      if (deliveryman.role !== 'DELIVERYMAN') throw new ValidationError('Deliveryman must have DELIVERYMAN role');
    }

    // Validar regras de cancelamento: só pode cancelar antes de IN_PROGRESS
    if (nextStatus === 'CANCELLED' && delivery.status === 'IN_PROGRESS') {
      throw new ValidationError('Cannot cancel a delivery that is already in progress');
    }

    const updated = await deliveriesRepository.updateStatus(id, nextStatus, deliverymanId);
    return updated;
  },
};
