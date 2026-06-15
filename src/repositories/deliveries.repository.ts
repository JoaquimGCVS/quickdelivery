import { Prisma } from '@prisma/client';
import { prisma } from '../infrastructure/prisma';
import { DeliveryStatus } from '../types/delivery-status';

const deliveryInclude = {
  customer: {
    select: { id: true, email: true, name: true, phone: true, role: true },
  },
  deliveryman: {
    select: { id: true, email: true, name: true, phone: true, role: true },
  },
} satisfies Prisma.DeliveryInclude;

export const deliveriesRepository = {
  create(data: {
    customerId: string;
    pickupAddress: string;
    dropoffAddress: string;
    description: string;
  }) {
    return prisma.delivery.create({ data, include: deliveryInclude });
  },
  findById(id: string) {
    return prisma.delivery.findUnique({ where: { id }, include: deliveryInclude });
  },
  findMany(filters: { status?: DeliveryStatus; deliverymanId?: string; customerId?: string }) {
    const where: Prisma.DeliveryWhereInput = {};
    if (filters.status) where.status = filters.status;
    if (filters.deliverymanId) where.deliverymanId = filters.deliverymanId;
    if (filters.customerId) where.customerId = filters.customerId;
    return prisma.delivery.findMany({ where, include: deliveryInclude, orderBy: { createdAt: 'desc' } });
  },
  findPending() {
    return prisma.delivery.findMany({
      where: { status: 'PENDING' },
      include: deliveryInclude,
      orderBy: { createdAt: 'desc' },
    });
  },
  findPendingOrAssigned(deliverymanId: string) {
    return prisma.delivery.findMany({
      where: {
        OR: [
          { status: 'PENDING' },
          { deliverymanId },
        ],
      },
      include: deliveryInclude,
      orderBy: { createdAt: 'desc' },
    });
  },
  updateStatus(id: string, status: DeliveryStatus, deliverymanId?: string) {
    return prisma.delivery.update({
      where: { id },
      data: {
        status,
        ...(deliverymanId !== undefined ? { deliverymanId } : {}),
      },
      include: deliveryInclude,
    });
  },
};
