import { prisma } from '../infrastructure/prisma';

export const providersRepository = {
  create(data: { name: string; phone: string }) {
    return prisma.provider.create({ data });
  },
  findById(id: string) {
    return prisma.provider.findUnique({ where: { id } });
  },
  findAll() {
    return prisma.provider.findMany({ orderBy: { createdAt: 'desc' } });
  },
};
