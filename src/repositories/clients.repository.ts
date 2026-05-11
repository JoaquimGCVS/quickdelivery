import { prisma } from '../infrastructure/prisma';

export const clientsRepository = {
  create(data: { name: string; phone: string }) {
    return prisma.client.create({ data });
  },
  findById(id: string) {
    return prisma.client.findUnique({ where: { id } });
  },
  findAll() {
    return prisma.client.findMany({ orderBy: { createdAt: 'desc' } });
  },
};
