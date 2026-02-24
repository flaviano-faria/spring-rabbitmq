# Spring RabbitMQ Payment Service

A Spring Boot microservice for asynchronous payment processing with RabbitMQ.

## Overview

This service receives payment requests through REST and publishes messages to RabbitMQ.

Flow:

1. Client sends `POST /payments`
2. `PaymentController` receives request
3. `PaymentService` delegates to `PaymentProducer`
4. `PaymentProducer` publishes to exchange `payment-exchange` with routing key `payment-rk`
5. `PaymentConsumer` listens on queue `payment-queue`

## Tech Stack

- Java 17
- Spring Boot 4.0.2
- Spring AMQP
- Spring Web MVC
- Maven
- RabbitMQ

## Prerequisites

- JDK 17 or higher
- Maven 3.6 or higher
- RabbitMQ running locally or in Docker

## Quick Start

### 1) Start RabbitMQ (Docker)

```bash
docker run -d --name rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:3-management
```

Management UI: `http://localhost:15672`  
Default user/password: `guest` / `guest`

### 2) Build and run the app

```bash
mvn clean install
mvn spring-boot:run
```

### 3) Send a test request

```bash
curl -X POST http://localhost:8080/payments \
  -H "Content-Type: application/json" \
  -d "{\"id\":\"PAY-001\",\"dateTime\":\"2024-01-15T10:30:00\",\"value\":\"100.50\"}"
```

## API

### POST /payments

Request body:

```json
{
  "id": "string",
  "dateTime": "string",
  "value": "string"
}
```

Response:

- `200 OK` or `204 No Content`
- Empty body

## RabbitMQ Setup

Create these resources:

- Exchange: `payment-exchange` (type: direct, durable)
- Queue: `payment-queue` (durable)
- Binding: `payment-queue` -> `payment-exchange` with key `payment-rk`

## Project Structure

```text
src/main/java/com/springrabbitmq/
  SpringRabbitmqApplication.java
  controller/PaymentController.java
  service/PaymentService.java
  producer/PaymentProducer.java
  consumer/PaymentConsumer.java
  dto/PaymentDTO.java
src/main/resources/application.properties
http-requests/
pom.xml
```

## Testing

HTTP test files are under `http-requests/`:

- `PaymentController.http`
- `PaymentController.curl.sh`
- `PaymentController.curl.ps1`
- `PaymentController.postman_collection.json`

Run tests:

```bash
mvn test
mvn verify
```

## Troubleshooting

- Connection refused: check RabbitMQ host/port and if broker is running
- Exchange not found: create exchange/queue/binding
- Port 8080 in use: set `server.port=8081`

Debug logging:

```properties
logging.level.com.springrabbitmq=DEBUG
logging.level.org.springframework.amqp=DEBUG
```

## Contributing

Fork the repository, create a branch, commit your changes, and open a pull request.

# Spring RabbitMQ Payment Service

A Spring Boot microservice for asynchronous payment processing using RabbitMQ.

Accepts payment requests via REST API and publishes them to a RabbitMQ exchange.

---

## Table of Contents

- [Quick Start](#quick-start)
- [Overview](#overview)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [API Documentation](#api-documentation)
- [RabbitMQ Setup](#rabbitmq-setup)
- [Running](#running)
- [Testing](#testing)
- [Project Structure](#project-structure)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

---

## Quick Start

### 1. Start RabbitMQ (Docker)

```bash
docker run -d --name rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:3-management
```

### 2. Create RabbitMQ resources

In Management UI: http://localhost:15672

- Exchange: payment-exchange (direct)
- Queue: payment-queue
- Binding: payment-queue to payment-exchange with key payment-rk

### 3. Build and run

```bash
mvn clean install
mvn spring-boot:run
```

### 4. Test

```bash
curl -X POST http://localhost:8080/payments -H "Content-Type: application/json" -d "{\"id\":\"PAY-001\",\"dateTime\":\"2024-01-15T10:30:00\",\"value\":\"100.50\"}"
```

---

## Overview

REST API receives payment requests.

PaymentService calls PaymentProducer which publishes to RabbitMQ.

PaymentConsumer listens on payment-queue and processes messages.

---

## Architecture

```
Client --> PaymentController --> PaymentService --> PaymentProducer --> RabbitMQ
                                                                              |
                                                                              v
                                                          PaymentConsumer <-- payment-queue
```

---

## Tech Stack

- Java 17
- Spring Boot 4.0.2
- Spring AMQP
- Spring Web MVC
- Maven
- RabbitMQ
- Jackson

---

## Prerequisites

- JDK 17+
- Maven 3.6+
- RabbitMQ 3.8+

---

## Installation

```bash
git clone <repository-url>
cd spring-rabbitmq
mvn clean install
```

---

## Configuration

**File:** `src/main/resources/application.properties`

```properties
spring.application.name=spring-rabbitmq
```

**RabbitMQ defaults:**

- localhost:5672
- user: guest
- password: guest

**Resources:**

- Exchange: payment-exchange
- Queue: payment-queue
- Routing key: payment-rk

---

## API Documentation

**Endpoint:** POST http://localhost:8080/payments

**Content-Type:** application/json

**Body:**

```json
{
  "id": "string",
  "dateTime": "string",
  "value": "string"
}
```

**Example:**

```json
{
  "id": "PAY-001",
  "dateTime": "2024-01-15T10:30:00",
  "value": "100.50"
}
```

**Response:** 200 OK, empty body

---

## RabbitMQ Setup

**Management UI:** http://localhost:15672 (guest/guest)

1. Create exchange payment-exchange (direct, durable)
2. Create queue payment-queue (durable)
3. Bind queue to exchange with routing key payment-rk

Or add RabbitMQConfig class with @Bean for DirectExchange, Queue, Binding.

---

## Running

```bash
mvn spring-boot:run
```

Or run SpringRabbitmqApplication.java in IDE.

---

## Testing

**HTTP test files** in http-requests/:

- PaymentController.http
- PaymentController.curl.sh
- PaymentController.curl.ps1
- PaymentController.postman_collection.json

See http-requests/README.md

```bash
mvn test
mvn verify
```

---

## Project Structure

```
src/main/java/com/springrabbitmq/
  SpringRabbitmqApplication.java
  controller/PaymentController.java
  consumer/PaymentConsumer.java
  dto/PaymentDTO.java
  service/PaymentService.java
  producer/PaymentProducer.java
src/main/resources/application.properties
http-requests/
pom.xml
```

---

## Troubleshooting

| Issue              | Solution                                      |
|--------------------|-----------------------------------------------|
| Connection refused | Start RabbitMQ, check application.properties  |
| NOT_FOUND exchange | Create exchange/queue or add @Configuration   |
| Port 8080 in use   | Set server.port=8081 in application.properties|
| Maven fails        | Run mvn clean dependency:resolve              |

**Debug logging** - add to application.properties:

```properties
logging.level.com.springrabbitmq=DEBUG
logging.level.org.springframework.amqp=DEBUG
```

---

## Contributing

Fork, create branch, commit, push, open Pull Request.
