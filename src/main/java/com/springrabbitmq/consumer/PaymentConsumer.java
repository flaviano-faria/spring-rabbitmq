package com.springrabbitmq.consumer;

import com.springrabbitmq.dto.PaymentDTO;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.stereotype.Component;

@Component
public class PaymentConsumer {

    @RabbitListener(queues = {"payment-queue"})
    public void process(@Payload String message){
        System.out.println("Message received: " + message);
    }
}
