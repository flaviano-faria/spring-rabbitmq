package com.springrabbitmq.service;

import com.springrabbitmq.dto.PaymentDTO;
import com.springrabbitmq.producer.PaymentProducer;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class PaymentService {

    @Autowired
    private PaymentProducer paymentProducer;

    public void sendPayment(PaymentDTO paymentDTO) {
        paymentProducer.sendPayment(paymentDTO);
    }
}
