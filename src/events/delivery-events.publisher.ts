import crypto from 'crypto';
import { Delivery } from '@prisma/client';
import { publishMessage } from '../infrastructure/rabbitmq';
import { DeliveryStatus } from '../types/delivery-status';

type DeliveryEventName = 'delivery.created' | 'delivery.accepted' | 'delivery.status_changed';

interface DeliveryEvent<TData> {
  eventId: string;
  eventName: DeliveryEventName;
  occurredAt: string;
  data: TData;
}

function buildEvent<TData>(eventName: DeliveryEventName, data: TData): DeliveryEvent<TData> {
  return {
    eventId: crypto.randomUUID(),
    eventName,
    occurredAt: new Date().toISOString(),
    data,
  };
}

async function publishDeliveryEvent<TData>(routingKey: DeliveryEventName, data: TData): Promise<void> {
  const event = buildEvent(routingKey, data);

  try {
    await publishMessage(routingKey, event, {
      messageId: event.eventId,
      type: event.eventName,
    });
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    console.error(`[rabbitmq] failed to publish ${routingKey}: ${message}`);
  }
}

export const deliveryEventsPublisher = {
  async publishCreated(delivery: Delivery) {
    await publishDeliveryEvent('delivery.created', {
      deliveryId: delivery.id,
      customerId: delivery.customerId,
      pickupAddress: delivery.pickupAddress,
      dropoffAddress: delivery.dropoffAddress,
      description: delivery.description,
      status: delivery.status,
    });
  },

  async publishAccepted(delivery: Delivery) {
    await publishDeliveryEvent('delivery.accepted', {
      deliveryId: delivery.id,
      customerId: delivery.customerId,
      deliverymanId: delivery.deliverymanId,
      status: delivery.status,
    });
  },

  async publishStatusChanged(
    delivery: Delivery,
    previousStatus: DeliveryStatus,
    currentStatus: DeliveryStatus,
  ) {
    await publishDeliveryEvent('delivery.status_changed', {
      deliveryId: delivery.id,
      customerId: delivery.customerId,
      deliverymanId: delivery.deliverymanId,
      previousStatus,
      currentStatus,
    });
  },
};
