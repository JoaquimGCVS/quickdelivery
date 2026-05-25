import 'dotenv/config';
import crypto from 'crypto';
import { prismaClient } from './infrastructure/prisma';

function hashPassword(password: string): string {
  return crypto.createHash('sha256').update(password).digest('hex');
}

async function main() {
  console.log('🌱 Seeding database...');

  // Limpar dados existentes
  await prismaClient.delivery.deleteMany();
  await prismaClient.user.deleteMany();

  // Criar 2 customers
  const customer1 = await prismaClient.user.create({
    data: {
      email: 'customer1@example.com',
      password: hashPassword('password123'),
      name: 'João Silva',
      phone: '11999999999',
      role: 'CUSTOMER',
    },
  });

  const customer2 = await prismaClient.user.create({
    data: {
      email: 'customer2@example.com',
      password: hashPassword('password123'),
      name: 'Maria Santos',
      phone: '11988888888',
      role: 'CUSTOMER',
    },
  });

  // Criar 2 deliverymen
  const deliveryman1 = await prismaClient.user.create({
    data: {
      email: 'deliveryman1@example.com',
      password: hashPassword('password123'),
      name: 'Pedro Oliveira',
      phone: '11977777777',
      role: 'DELIVERYMAN',
    },
  });

  const deliveryman2 = await prismaClient.user.create({
    data: {
      email: 'deliveryman2@example.com',
      password: hashPassword('password123'),
      name: 'Carlos Costa',
      phone: '11966666666',
      role: 'DELIVERYMAN',
    },
  });

  // Criar entregas com diferentes status
  const deliveryPending = await prismaClient.delivery.create({
    data: {
      customerId: customer1.id,
      pickupAddress: 'Rua A, 100 - São Paulo',
      dropoffAddress: 'Rua B, 200 - São Paulo',
      description: 'Entrega pendente',
      status: 'PENDING',
    },
  });

  const deliveryAccepted = await prismaClient.delivery.create({
    data: {
      customerId: customer1.id,
      deliverymanId: deliveryman1.id,
      pickupAddress: 'Rua C, 300 - São Paulo',
      dropoffAddress: 'Rua D, 400 - São Paulo',
      description: 'Entrega aceita',
      status: 'ACCEPTED',
    },
  });

  const deliveryInProgress = await prismaClient.delivery.create({
    data: {
      customerId: customer2.id,
      deliverymanId: deliveryman2.id,
      pickupAddress: 'Rua E, 500 - São Paulo',
      dropoffAddress: 'Rua F, 600 - São Paulo',
      description: 'Entrega em andamento',
      status: 'IN_PROGRESS',
    },
  });

  const deliveryDelivered = await prismaClient.delivery.create({
    data: {
      customerId: customer2.id,
      deliverymanId: deliveryman1.id,
      pickupAddress: 'Rua G, 700 - São Paulo',
      dropoffAddress: 'Rua H, 800 - São Paulo',
      description: 'Entrega entregue',
      status: 'DELIVERED',
    },
  });

  const deliveryCancelled = await prismaClient.delivery.create({
    data: {
      customerId: customer1.id,
      pickupAddress: 'Rua I, 900 - São Paulo',
      dropoffAddress: 'Rua J, 1000 - São Paulo',
      description: 'Entrega cancelada',
      status: 'CANCELLED',
    },
  });

  console.log('✅ Database seeded successfully!');
  console.log('📦 Customers:');
  console.log(`  - ${customer1.name} (${customer1.email})`);
  console.log(`  - ${customer2.name} (${customer2.email})`);
  console.log('🚚 Deliverymen:');
  console.log(`  - ${deliveryman1.name} (${deliveryman1.email})`);
  console.log(`  - ${deliveryman2.name} (${deliveryman2.email})`);
  console.log('📮 Deliveries:');
  console.log(`  - ${deliveryPending.status}`);
  console.log(`  - ${deliveryAccepted.status}`);
  console.log(`  - ${deliveryInProgress.status}`);
  console.log(`  - ${deliveryDelivered.status}`);
  console.log(`  - ${deliveryCancelled.status}`);
  console.log('\n💡 Test credentials:');
  console.log('Customer 1: customer1@example.com / password123');
  console.log('Customer 2: customer2@example.com / password123');
  console.log('Deliveryman 1: deliveryman1@example.com / password123');
  console.log('Deliveryman 2: deliveryman2@example.com / password123');
}

main()
  .catch((e) => {
    console.error('❌ Seeding failed:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prismaClient.$disconnect();
  });
