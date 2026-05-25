import { prismaClient } from '../infrastructure/prisma';
import { UserRole } from '../types/user';

export const usersRepository = {
  async create(data: { email: string; password: string; name: string; phone: string; role: UserRole }) {
    return prismaClient.user.create({
      data,
      select: { id: true, email: true, name: true, phone: true, role: true, createdAt: true },
    });
  },

  async findById(id: string) {
    return prismaClient.user.findUnique({
      where: { id },
      select: { id: true, email: true, name: true, phone: true, role: true, createdAt: true },
    });
  },

  async findByEmail(email: string) {
    return prismaClient.user.findUnique({
      where: { email },
      select: { id: true, email: true, name: true, phone: true, role: true, createdAt: true, password: true },
    });
  },

  async findMany(role?: UserRole) {
    return prismaClient.user.findMany({
      where: role ? { role } : undefined,
      select: { id: true, email: true, name: true, phone: true, role: true, createdAt: true },
    });
  },

  async delete(id: string) {
    return prismaClient.user.delete({
      where: { id },
      select: { id: true, email: true, name: true, phone: true, role: true },
    });
  },
};
