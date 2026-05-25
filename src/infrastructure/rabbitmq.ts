import amqp, { ChannelModel, ConfirmChannel, Options } from 'amqplib';

const DEFAULT_RABBITMQ_URL = 'amqp://quickdelivery:quickdelivery@localhost:5672';
const DEFAULT_EXCHANGE = 'quickdelivery.events';

let connection: ChannelModel | null = null;
let channel: ConfirmChannel | null = null;

export const rabbitmqConfig = {
  url: process.env.RABBITMQ_URL || DEFAULT_RABBITMQ_URL,
  exchange: process.env.RABBITMQ_EXCHANGE || DEFAULT_EXCHANGE,
  deliveryEventsQueue: process.env.RABBITMQ_DELIVERY_EVENTS_QUEUE || 'quickdelivery.delivery-events',
};

export async function getRabbitChannel(): Promise<ConfirmChannel> {
  if (channel) return channel;

  connection = await amqp.connect(rabbitmqConfig.url);
  connection.on('close', () => {
    connection = null;
    channel = null;
  });
  connection.on('error', (err) => {
    console.error('[rabbitmq] connection error:', err.message);
  });

  channel = await connection.createConfirmChannel();
  await channel.assertExchange(rabbitmqConfig.exchange, 'topic', { durable: true });

  return channel;
}

export async function publishMessage(
  routingKey: string,
  payload: unknown,
  options: Options.Publish = {},
): Promise<void> {
  const ch = await getRabbitChannel();
  const body = Buffer.from(JSON.stringify(payload));

  await new Promise<void>((resolve, reject) => {
    ch.publish(
      rabbitmqConfig.exchange,
      routingKey,
      body,
      {
        contentType: 'application/json',
        deliveryMode: 2,
        timestamp: Math.floor(Date.now() / 1000),
        ...options,
      },
      (err) => {
        if (err) reject(err);
        else resolve();
      },
    );
  });
}

export async function closeRabbitConnection(): Promise<void> {
  if (channel) {
    await channel.close();
    channel = null;
  }
  if (connection) {
    await connection.close();
    connection = null;
  }
}
