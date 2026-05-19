import { Prisma } from '@prisma/client';
import { prisma } from '../infrastructure/prisma';
import { DeliveryStatus } from '../types/delivery-status';

export const deliveriesRepository = {
  create(data: {
    customerId: string;
    pickupAddress: string;
    dropoffAddress: string;
    description: string;
  }) {
    return prisma.delivery.create({ data });
  },
  findById(id: string) {
    return prisma.delivery.findUnique({ where: { id } });
  },
  findMany(filters: { status?: DeliveryStatus; deliverymanId?: string; customerId?: string }) {
    const where: Prisma.DeliveryWhereInput = {};
    if (filters.status) where.status = filters.status;
    if (filters.deliverymanId) where.deliverymanId = filters.deliverymanId;
    if (filters.customerId) where.customerId = filters.customerId;
    return prisma.delivery.findMany({ where, orderBy: { createdAt: 'desc' } });
  },
  updateStatus(id: string, status: DeliveryStatus, deliverymanId?: string) {
    return prisma.delivery.update({
      where: { id },
      data: {
        status,
        ...(deliverymanId !== undefined ? { deliverymanId } : {}),
      },
    });
  },
};
