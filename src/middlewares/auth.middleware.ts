import { NextFunction, Request, Response } from 'express';
import { authService } from '../services/auth.service';
import { UnauthorizedError } from './error-handler';

export interface AuthenticatedRequest extends Request {
  user?: { userId: string; role: string };
}

export function authMiddleware(req: AuthenticatedRequest, _res: Response, next: NextFunction) {
  const auth = authService.parseToken(req.headers.authorization);
  if (!auth) {
    return next(new UnauthorizedError('Missing or invalid token'));
  }
  req.user = auth;
  next();
}

export function requireRole(...roles: string[]) {
  return (req: AuthenticatedRequest, _res: Response, next: NextFunction) => {
    if (!req.user || !roles.includes(req.user.role)) {
      return next(new UnauthorizedError('Insufficient permissions'));
    }
    next();
  };
}
