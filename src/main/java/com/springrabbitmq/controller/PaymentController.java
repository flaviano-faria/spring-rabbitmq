package com.springrabbitmq.controller;

import com.springrabbitmq.dto.PaymentDTO;
import com.springrabbitmq.service.PaymentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class PaymentController {

    @Autowired
    private PaymentService paymentService;

    @PostMapping(value = "/payments")
    public void sendPayment(@RequestBody PaymentDTO paymentDTO) {
        paymentService.sendPayment(paymentDTO);
    }
}
