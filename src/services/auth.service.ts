import crypto from 'crypto';
import { ValidationError, UnauthorizedError, NotFoundError } from '../middlewares/error-handler';
import { usersRepository } from '../repositories/users.repository';
import { UserRole } from '../types/user';

const JWT_SECRET = process.env.JWT_SECRET || 'super-secret-key-change-in-prod';
const TOKEN_EXPIRATION = 3600; // 1 hora em segundos

function validateEmail(email: string): boolean {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
}

function hashPassword(password: string): string {
  return crypto.createHash('sha256').update(password).digest('hex');
}

function verifyPassword(password: string, hash: string): boolean {
  const computed = hashPassword(password);
  return computed === hash;
}

function generateToken(userId: string, role: UserRole): string {
  const payload = {
    userId,
    role,
    iat: Math.floor(Date.now() / 1000),
    exp: Math.floor(Date.now() / 1000) + TOKEN_EXPIRATION,
  };

  const headerEncoded = Buffer.from(JSON.stringify({ alg: 'HS256', typ: 'JWT' })).toString('base64url');
  const payloadEncoded = Buffer.from(JSON.stringify(payload)).toString('base64url');

  const signature = crypto
    .createHmac('sha256', JWT_SECRET)
    .update(`${headerEncoded}.${payloadEncoded}`)
    .digest('base64url');

  return `${headerEncoded}.${payloadEncoded}.${signature}`;
}

function verifyToken(token: string): { userId: string; role: UserRole } | null {
  try {
    const parts = token.split('.');
    if (parts.length !== 3) return null;

    const headerEncoded = parts[0];
    const payloadEncoded = parts[1];
    const signature = parts[2];

    const expectedSignature = crypto
      .createHmac('sha256', JWT_SECRET)
      .update(`${headerEncoded}.${payloadEncoded}`)
      .digest('base64url');

    if (signature !== expectedSignature) return null;

    const payload = JSON.parse(Buffer.from(payloadEncoded, 'base64url').toString());

    if (payload.exp < Math.floor(Date.now() / 1000)) return null;

    return { userId: payload.userId, role: payload.role };
  } catch {
    return null;
  }
}

export const authService = {
  async signup(input: {
    email?: unknown;
    password?: unknown;
    name?: unknown;
    phone?: unknown;
    role?: unknown;
  }) {
    if (typeof input.email !== 'string' || !input.email.trim()) {
      throw new ValidationError('Field "email" is required');
    }
    if (!validateEmail(input.email)) {
      throw new ValidationError('Invalid email format');
    }
    if (typeof input.password !== 'string' || !input.password.trim()) {
      throw new ValidationError('Field "password" is required');
    }
    if (input.password.length < 6) {
      throw new ValidationError('Password must be at least 6 characters');
    }
    if (typeof input.name !== 'string' || !input.name.trim()) {
      throw new ValidationError('Field "name" is required');
    }
    if (typeof input.phone !== 'string' || !input.phone.trim()) {
      throw new ValidationError('Field "phone" is required');
    }
    if (typeof input.role !== 'string' || !['CUSTOMER', 'DELIVERYMAN'].includes(input.role)) {
      throw new ValidationError('Field "role" must be CUSTOMER or DELIVERYMAN');
    }

    const existing = await usersRepository.findByEmail(input.email);
    if (existing) {
      throw new ValidationError('Email already in use');
    }

    const hashedPassword = hashPassword(input.password);
    const user = await usersRepository.create({
      email: input.email,
      password: hashedPassword,
      name: input.name,
      phone: input.phone,
      role: input.role as UserRole,
    });

    const token = generateToken(user.id, user.role);
    return { user, token };
  },

  async login(input: { email?: unknown; password?: unknown }) {
    if (typeof input.email !== 'string' || !input.email.trim()) {
      throw new ValidationError('Field "email" is required');
    }
    if (typeof input.password !== 'string') {
      throw new ValidationError('Field "password" is required');
    }

    const user = await usersRepository.findByEmail(input.email);
    if (!user || !verifyPassword(input.password, user.password)) {
      throw new UnauthorizedError('Invalid email or password');
    }

    const token = generateToken(user.id, user.role);
    return { user: { id: user.id, email: user.email, name: user.name, phone: user.phone, role: user.role, createdAt: user.createdAt }, token };
  },

  parseToken(authHeader: string | undefined): { userId: string; role: UserRole } | null {
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return null;
    }
    const token = authHeader.slice(7);
    return verifyToken(token);
  },
};
