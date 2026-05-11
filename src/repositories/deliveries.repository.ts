import { Prisma } from '@prisma/client';
import { prisma } from '../infrastructure/prisma';
import { DeliveryStatus } from '../types/delivery-status';

export const deliveriesRepository = {
  create(data: {
    clientId: string;
    pickupAddress: string;
    dropoffAddress: string;
    description: string;
  }) {
    return prisma.delivery.create({ data });
  },
  findById(id: string) {
    return prisma.delivery.findUnique({ where: { id } });
  },
  findMany(filters: { status?: DeliveryStatus; providerId?: string }) {
    const where: Prisma.DeliveryWhereInput = {};
    if (filters.status) where.status = filters.status;
    if (filters.providerId) where.providerId = filters.providerId;
    return prisma.delivery.findMany({ where, orderBy: { createdAt: 'desc' } });
  },
  updateStatus(id: string, status: DeliveryStatus, providerId?: string) {
    return prisma.delivery.update({
      where: { id },
      data: {
        status,
        ...(providerId !== undefined ? { providerId } : {}),
      },
    });
  },
};
