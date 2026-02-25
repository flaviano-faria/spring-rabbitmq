# RabbitMQ Learning Roadmap (Beginner to Advanced)

This roadmap is designed to take you from RabbitMQ fundamentals to production-level expertise.
It includes:

- A progressive study path
- Hands-on exercises at each level
- Troubleshooting workflows
- Useful commands for day-to-day operations
- A suggested 12-week plan

---

## 1) Prerequisites (Before RabbitMQ)

Make sure you are comfortable with:

- Basic networking: ports, DNS, TCP connections
- HTTP/REST basics
- JSON serialization/deserialization
- Java + Spring Boot basics (if using this repository)
- Docker basics (run, logs, exec, inspect)

If any of these are weak, spend 2-3 days refreshing first.

---

## 2) Learning Stages Overview

1. **Foundation** - Core AMQP concepts and local setup
2. **Core Messaging Patterns** - Routing strategies and consumer behavior
3. **Reliability & Safety** - Delivery guarantees, retries, DLQ
4. **Performance & Scaling** - Throughput tuning and architecture decisions
5. **Operations & Production** - Monitoring, troubleshooting, incident response
6. **Advanced Topics** - Clustering, quorum queues, streams, federation

---

## 2.1) Deep Dive Per Stage

### 1) Foundation (Core AMQP + Local Setup)

#### What to Understand

- Why brokers exist: decoupling, async workflows, and traffic buffering
- AMQP primitives: producer, consumer, exchange, queue, binding, routing key
- Delivery basics: durable queue, persistent message, acknowledgements

#### What to Practice

- Run RabbitMQ locally and navigate Management UI confidently
- Create exchange, queue, and binding manually
- Publish/consume messages and track queue states (`ready`, `unacked`, `total`)

#### Common Beginner Mistakes

- Assuming durable queues alone prevent message loss
- Mixing up exchange behavior (`direct`, `topic`, `fanout`)
- Using default user/vhost without understanding permissions

### 2) Core Messaging Patterns (Routing + Consumer Behavior)

#### What to Understand

- `direct` for exact match, `topic` for wildcard pattern routing, `fanout` for broadcast
- Competing consumers and their impact on ordering
- Message schema/versioning strategy for backward compatibility

#### What to Practice

- Implement one flow for each exchange type
- Add multiple consumers and observe load distribution
- Validate routing patterns like `payment.*` and `payment.#`

#### Design Decisions

- When to isolate high-priority flows into separate queues
- When one queue with multiple consumers is enough

### 3) Reliability & Safety (Guarantees, Retries, DLQ)

#### What to Understand

- At-least-once delivery and why duplicates happen
- Publisher confirms and manual consumer acknowledgements
- DLX/DLQ strategies for poison messages and controlled retries

#### What to Practice

- Force processing errors and observe retry/dead-letter path
- Implement idempotency key checks in consumer logic
- Apply fixed or exponential backoff retry with max-attempt protection

#### Critical Production Mindset

- Prevent infinite requeue loops
- Separate transient failures from invalid-message failures

### 4) Performance & Scaling (Throughput + Architecture Choices)

#### What to Understand

- Prefetch and backpressure impact (`basic.qos`)
- Ordering vs parallelism trade-offs
- Broker limits: memory alarms, disk pressure, backlog effects

#### What to Practice

- Load test with different payload sizes and consumer counts
- Tune prefetch, concurrency, and queue topology
- Measure publish rate, ack rate, and queue lag before/after changes

#### Common Tuning Pitfalls

- Oversized prefetch causing long unacked queues
- Scaling consumers without validating downstream dependencies

### 5) Operations & Production (Monitoring + Incident Response)

#### What to Understand

- Core operating signals: queue depth, unacked messages, consumer count, broker alarms
- SLO-based alerting and incident severity classification
- Runbooks for triage, mitigation, and recovery

#### What to Practice

- Build dashboards with broker and app metrics
- Configure alerts for queue growth, missing consumers, and high unacked counts
- Run controlled incident drills (consumer crash, routing issue, broker pressure)

#### Operational Maturity Signal

- You can quickly determine whether the issue is producer-side, broker-side, or consumer-side

### 6) Advanced Topics (Cluster, Quorum, Streams, Federation)

#### What to Understand

- Quorum queues: stronger consistency/safety with different performance profile
- Classic queues: simpler behavior with different trade-offs
- Streams: append-log style messaging for high-throughput and replay use cases
- Federation/Shovel: cross-broker and cross-region message movement

#### What to Practice

- Deploy multi-node RabbitMQ and run failure drills
- Compare classic vs quorum behavior under node restarts/failures
- Evaluate when stream semantics match business requirements

#### Architecture Trade-Offs

- Balance reliability, latency, cost, and operational complexity
- Treat exactly-once as an application design goal (idempotency + dedup), not a broker default

---

## 3) Stage-by-Stage Roadmap

## Stage 1 - Foundation (Week 1-2)

### Goals

- Understand what RabbitMQ solves and when to use it
- Learn the core entities: producer, consumer, queue, exchange, binding, routing key
- Run RabbitMQ locally and explore the Management UI

### Topics

- Message broker vs direct service-to-service communication
- AMQP model
- Exchange types:
  - direct
  - fanout
  - topic
  - headers (less common)
- Queue durability, message persistence, acknowledgements
- Virtual hosts and users

### Hands-on

- Start RabbitMQ with management plugin:

```bash
docker run -d --name rabbitmq ^
  -p 5672:5672 -p 15672:15672 ^
  rabbitmq:3-management
```

- Use your current Spring project to:
  - Publish a message
  - Consume a message
  - Verify message flow in the UI

### Exit Criteria

- You can explain message flow from producer to consumer
- You can create queue/exchange/binding manually in UI
- You can send and receive at least one message end-to-end

---

## Stage 2 - Core Messaging Patterns (Week 3-4)

### Goals

- Master routing behavior
- Understand consumer concurrency and ordering implications
- Implement message contracts correctly

### Topics

- Routing patterns:
  - direct routing (exact match)
  - topic routing (wildcards `*` and `#`)
  - pub/sub with fanout
- Competing consumers
- Message ordering constraints
- TTL (message/queue), auto-delete, exclusive queues
- Serialization choices (JSON, Avro, Protobuf)

### Hands-on

- Implement 3 sample flows in code:
  - Event broadcast (fanout)
  - Selective routing (topic)
  - Work queue with multiple consumers
- Test wildcard routing keys:
  - `payment.created`
  - `payment.failed`
  - `payment.*`
  - `payment.#`

### Exit Criteria

- You can choose the right exchange type by use case
- You can reason about ordering and parallel consumers
- You can define a stable message schema for integration

---

## Stage 3 - Reliability & Failure Handling (Week 5-6)

### Goals

- Build resilient message processing
- Prevent message loss and poison-message loops

### Topics

- Publisher confirms
- Consumer acks: manual vs auto
- Requeue behavior
- Dead-letter exchanges (DLX) and dead-letter queues (DLQ)
- Retry strategies:
  - immediate retry
  - delayed retry (TTL + DLX)
  - exponential backoff
- Idempotency and deduplication

### Hands-on

- Enable publisher confirms in producer
- Force consumer exceptions and observe requeue behavior
- Configure DLQ and route failed messages
- Add idempotency key handling in consumer logic

### Exit Criteria

- Failed messages are visible and recoverable
- Poison messages do not block the entire queue
- Duplicate deliveries do not break business logic

---

## Stage 4 - Performance & Scaling (Week 7-8)

### Goals

- Tune throughput and latency
- Scale consumers safely

### Topics

- Prefetch (`basic.qos`) and consumer backpressure
- Throughput vs ordering trade-offs
- Queue length limits and overflow policies
- Lazy queues, memory/disk alarms
- Partitioning workloads by routing key
- Connection/channel management best practices

### Hands-on

- Load test publish/consume rates
- Tune:
  - prefetch
  - consumer concurrency
  - message payload size
- Compare performance before/after tuning

### Exit Criteria

- You can explain bottlenecks in your setup
- You can tune consumer settings for better throughput
- System remains stable under sustained load

---

## Stage 5 - Operations & Production Readiness (Week 9-10)

### Goals

- Operate RabbitMQ with confidence in real environments
- Detect and resolve incidents quickly

### Topics

- Monitoring metrics:
  - queue depth
  - publish/ack rates
  - unacked messages
  - consumer utilization
  - memory and disk alarms
- Alerting thresholds and SLO thinking
- Backup/restore definitions and policies
- Security hardening:
  - users/permissions
  - TLS
  - least privilege

### Hands-on

- Build a dashboard (Prometheus/Grafana or management metrics)
- Create alert rules for:
  - rapidly growing queues
  - no active consumers
  - high unacked counts
- Perform controlled failure drills

### Exit Criteria

- You can detect incidents before users report them
- You have runbooks for top failure modes
- You can safely recover from common outages

---

## Stage 6 - Advanced RabbitMQ (Week 11-12)

### Goals

- Understand advanced distributed messaging architecture choices

### Topics

- Quorum queues vs classic queues
- Streams and stream protocol basics
- Cluster design and node roles
- Federation and Shovel
- Multi-region strategies
- Exactly-once myth and practical at-least-once architecture

### Hands-on

- Spin up multi-node RabbitMQ in Docker Compose
- Compare classic and quorum queue behavior under failure
- Simulate node restarts and observe durability

### Exit Criteria

- You can choose queue type based on reliability/performance needs
- You understand cluster trade-offs and operational complexity
- You can document architecture decisions with clear rationale

---

## 4) Troubleshooting Playbook

Use this sequence when something breaks:

1. **Confirm connectivity**  
   Can producer/consumer reach RabbitMQ host and port 5672?

2. **Check broker health**  
   Any memory/disk alarms? Node running? Management UI reachable?

3. **Inspect queue state**  
   Ready vs unacked messages, consumer count, ingress/egress rates.

4. **Validate bindings/routing**  
   Exchange type, binding keys, and published routing key match expected pattern.

5. **Check acknowledgements**  
   Are consumers acking? Are messages repeatedly requeued?

6. **Inspect dead-letter flow**  
   Are failed messages landing in DLQ? If not, DLX policy may be wrong.

7. **Review logs and payloads**  
   Serialization mismatch? Schema drift? Business exceptions?

8. **Apply minimal safe fix**  
   Prefer pause, drain, reroute, then redeploy. Avoid blind restarts.

---

## 5) Common Failure Scenarios and Actions

- **Messages not arriving in queue**
  - Verify exchange exists and routing key matches a binding
  - Confirm producer publishes to correct vhost
  - Check permissions (`configure`, `write`, `read`)

- **Queue keeps growing**
  - Consumers down or too slow
  - Increase consumer instances/concurrency
  - Reduce processing time and tune prefetch

- **High unacked messages**
  - Consumer stuck or long processing
  - Check code paths for missing `ack`
  - Reduce prefetch and improve timeout/retry behavior

- **Poison message loop**
  - Message repeatedly fails and requeues
  - Add max-retry policy and DLQ route
  - Add validation/idempotency guards

- **Broker memory alarm triggered**
  - Large queue backlog or big messages
  - Enable lazy behavior where applicable
  - Increase resources or drain queues safely

---

## 6) Useful RabbitMQ Commands

> Use these inside the RabbitMQ container or host where `rabbitmqctl` and `rabbitmq-diagnostics` are installed.

### Broker and Node Status

```bash
rabbitmqctl status
rabbitmq-diagnostics ping
rabbitmq-diagnostics check_running
rabbitmq-diagnostics check_local_alarms
```

### Users, Vhosts, and Permissions

```bash
rabbitmqctl list_users
rabbitmqctl add_user app_user strong_password
rabbitmqctl add_vhost app_vhost
rabbitmqctl set_permissions -p app_vhost app_user ".*" ".*" ".*"
rabbitmqctl list_permissions -p app_vhost
```

### Queues and Consumers

```bash
rabbitmqctl list_queues name messages messages_ready messages_unacknowledged consumers
rabbitmqctl list_consumers
rabbitmqctl purge_queue payment-queue
```

### Exchanges and Bindings

```bash
rabbitmqctl list_exchanges name type durable
rabbitmqctl list_bindings
```

### Policies and DLQ Support

```bash
rabbitmqctl list_policies
rabbitmqctl set_policy DLQ "payment\..*" ^
  "{\"dead-letter-exchange\":\"payment.dlx\"}" --apply-to queues
```

### Useful Docker Commands

```bash
docker ps
docker logs rabbitmq
docker exec -it rabbitmq rabbitmqctl status
docker exec -it rabbitmq rabbitmqctl list_queues name messages_ready messages_unacknowledged consumers
```

### Management API (optional automation)

```bash
curl -u guest:guest http://localhost:15672/api/overview
curl -u guest:guest http://localhost:15672/api/queues
curl -u guest:guest http://localhost:15672/api/exchanges
```

---

## 7) Recommended Learning Resources

- Official RabbitMQ docs:
  - Tutorials
  - Queues
  - Exchanges and routing
  - Reliability and data safety
  - Quorum queues and streams
- Spring AMQP reference documentation
- Production incident write-ups/blogs from teams running RabbitMQ at scale

Tip: always validate internet advice against the RabbitMQ version you are using.

---

## 8) Practical Project Roadmap (For This Repository)

1. Add integration tests that spin RabbitMQ using Testcontainers.
2. Add explicit DLQ + retry configuration in Spring.
3. Add idempotency key check in consumer processing path.
4. Add metrics and dashboard for queue depth + processing latency.
5. Add runbook docs for incident handling.
6. Add load test scripts for publish/consume scenarios.

---

## 9) Self-Assessment Checklist

You are approaching advanced level when you can:

- Design exchange/queue topology from business requirements
- Explain and implement at-least-once processing safely
- Tune throughput without breaking ordering guarantees
- Build and use DLQ/retry workflows confidently
- Diagnose broker/client issues quickly from metrics and logs
- Operate RabbitMQ in production with clear runbooks

---

## 10) Suggested Weekly Study Schedule (12 Weeks)

- **Mon-Tue**: Learn concepts (docs + notes)
- **Wed-Thu**: Implement hands-on lab
- **Fri**: Break/fix exercise (intentional failures)
- **Sat**: Write a one-page summary of lessons learned
- **Sun**: Rest or lightweight review

Keep a learning log with:

- what failed
- how you diagnosed it
- what fixed it
- what alert/runbook should exist to catch it next time

That log is what turns knowledge into senior-level operational judgment.
