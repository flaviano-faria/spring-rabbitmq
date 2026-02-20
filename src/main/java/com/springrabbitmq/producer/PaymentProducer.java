package com.springrabbitmq.producer;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.springrabbitmq.dto.PaymentDTO;
import org.springframework.amqp.core.AmqpTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class PaymentProducer {

    @Autowired
    private AmqpTemplate amqpTemplate;
    private final ObjectMapper mapper = new ObjectMapper();

    public void sendPayment(PaymentDTO paymentDTO) {
        try {
            String paymentJson = mapper.writeValueAsString(paymentDTO);
            amqpTemplate.convertAndSend("payment-exchange",
                    "payment-rk",
                    paymentJson);
        } catch (JsonProcessingException e) {
            throw new RuntimeException("Failed to serialize payment DTO", e);
        }
    }
}
