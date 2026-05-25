import { UserRole } from '@prisma/client';

export { UserRole };

export interface AuthPayload {
  userId: string;
  role: UserRole;
  iat: number;
  exp: number;
}

export const USER_ROLES = {
  CUSTOMER: 'CUSTOMER' as const,
  DELIVERYMAN: 'DELIVERYMAN' as const,
};
