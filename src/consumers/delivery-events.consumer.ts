import 'dotenv/config';
import { getRabbitChannel, rabbitmqConfig } from '../infrastructure/rabbitmq';

const routingKeys = ['delivery.created', 'delivery.accepted', 'delivery.status_changed'];

async function main() {
  const channel = await getRabbitChannel();
  const queue = rabbitmqConfig.deliveryEventsQueue;

  await channel.assertQueue(queue, { durable: true });
  for (const routingKey of routingKeys) {
    await channel.bindQueue(queue, rabbitmqConfig.exchange, routingKey);
  }

  console.log(`[consumer] waiting for delivery events on queue "${queue}"`);

  await channel.consume(queue, (message) => {
    if (!message) return;

    try {
      const payload = JSON.parse(message.content.toString());
      console.log(`[consumer] ${message.fields.routingKey}`, JSON.stringify(payload, null, 2));
      channel.ack(message);
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : String(err);
      console.error(`[consumer] failed to process message: ${errorMessage}`);
      channel.nack(message, false, false);
    }
  });
}

main().catch((err) => {
  const message = err instanceof Error ? err.message : String(err);
  console.error(`[consumer] failed to start: ${message}`);
  process.exit(1);
});
