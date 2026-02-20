package com.springrabbitmq.producer;

import com.springrabbitmq.dto.PaymentDTO;
import org.springframework.amqp.core.AmqpTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import tools.jackson.databind.ObjectMapper;

@Service
public class PaymentProducer {

    @Autowired
    private AmqpTemplate amqpTemplate;
    private final ObjectMapper mapper = new ObjectMapper();

    public void sendPayment(PaymentDTO paymentDTO) {
        String paymentJson = mapper.writeValueAsString(paymentDTO);
        amqpTemplate.convertAndSend("payment-exchange",
                "payment-rk",
                paymentJson);
    }
}
