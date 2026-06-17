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
- Binding connects exchange to queue; routing key on publish must match binding key (direct) or pattern (topic)
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
- Binding key vs routing key: producer sets routing key; binding defines what the exchange matches
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

## 2.2) Bindings and Routing Keys (Deep Dive)

Bindings and routing keys are the core mechanism that decides **which queue receives which message**. Without a correct binding, messages are published successfully but never reach a consumer.

### What is a Routing Key?

A **routing key** is a string that the **producer attaches to a message** when publishing to an exchange.

Think of it as a **label on an envelope** — it tells the exchange where the message should go, but the exchange decides the final destination based on its rules and bindings.

**Key points:**

- Set by the **producer** at publish time
- Passed as the second argument in Spring AMQP: `convertAndSend(exchange, routingKey, message)`
- The exchange uses it to **match** against binding keys
- It is **not** the queue name (though with the default exchange, routing key equals queue name)
- It can be any string; conventions like `payment.created` or `order.shipped` improve readability

**Example from this project:**

```java
amqpTemplate.convertAndSend("payment-exchange", "payment-rk", paymentJson);
//                                    exchange         ↑
//                                              routing key
```

Here, `payment-rk` is the routing key. The producer says: "Send this message to `payment-exchange` and label it `payment-rk`."

**Analogy:** A routing key is like writing **"Billing Department"** on a package before dropping it at the central mail room (exchange). The mail room uses that label to decide which internal bins (queues) receive the package.

---

### What is a Binding?

A **binding** is a **rule that connects an exchange to a queue**. It tells the exchange: "When a message matches this rule, deliver it to this queue."

A binding has two parts:

1. **Which queue** receives the message
2. **Which messages** qualify — defined by the **binding key** (and exchange type)

**Key points:**

- Created by an **administrator or application config** (not by the producer at publish time)
- Without a binding, a queue will **never** receive messages from that exchange — even if the queue exists
- One queue can have **multiple bindings** (to different exchanges or with different keys)
- One exchange can have **many bindings** (to many queues)
- Bindings are **persistent** until explicitly removed

**Visual representation:**

```
                    payment-exchange (direct)
                           |
              binding: payment-rk
                           |
                           v
                    payment-queue  →  PaymentConsumer
```

**In RabbitMQ terms:**

```
Binding = Exchange + Queue + Binding Key (+ optional arguments)
```

**Analogy:** A binding is like a **mail sorting rule** at the central mail room: "All packages labeled `Billing Department` go to bin #3 (payment-queue)." The producer only writes the label; the binding rule decides which bin gets it.

---

### How Routing Key and Binding Work Together

| Who sets it | What | When |
|-------------|------|------|
| **Producer** | Routing key | At publish time (per message) |
| **Admin / Config** | Binding (with binding key) | Once, when topology is set up |

**The matching process:**

1. Producer publishes message to exchange with routing key `payment-rk`
2. Exchange looks at all bindings attached to it
3. For each binding, it compares routing key vs binding key (rules depend on exchange type)
4. Every matching binding forwards a copy of the message to its queue

**Simple direct exchange example:**

```
Producer publishes:  exchange=payment-exchange, routing key=payment-rk

Binding 1:  payment-queue     ← payment-exchange, binding key=payment-rk   ✓ MATCH
Binding 2:  audit-queue       ← payment-exchange, binding key=payment-rk   ✓ MATCH
Binding 3:  other-queue       ← payment-exchange, binding key=other-key    ✗ NO MATCH

Result: message goes to payment-queue AND audit-queue (not to other-queue)
```

**Important distinction:**

- **Routing key** = dynamic, chosen per message by the producer
- **Binding key** = static, defined when you create the binding
- They are often the **same value** in direct exchanges, but they play different roles

---

### Core Concepts

| Concept | Role |
|---------|------|
| **Exchange** | Receives messages from producers and routes them to queues |
| **Queue** | Stores messages until a consumer processes them |
| **Binding** | A link between an exchange and a queue, optionally with a **binding key** |
| **Routing key** | A string set by the producer on publish; the exchange uses it to match bindings |
| **Binding key** | The pattern or exact value on the binding side used for matching |

**Message flow:**

```
Producer → Exchange (routing key) → Binding match → Queue → Consumer
```

The producer never sends directly to a queue. It publishes to an exchange with a routing key. The exchange evaluates all bindings and forwards copies to every queue whose binding matches.

### Binding Key vs Routing Key

- On **publish**, the producer sets the **routing key** (e.g. `payment-rk`, `payment.created`).
- On **bind**, you attach a queue to an exchange with a **binding key** (or pattern).
- For `direct` and `topic` exchanges, matching rules compare routing key against binding key.
- For `fanout` exchanges, binding keys are ignored — every bound queue receives every message.
- For `headers` exchanges, matching uses message headers instead of routing keys.

### Behavior by Exchange Type

#### Direct Exchange (exact match)

- Routing key must **exactly equal** binding key.
- One routing key can match **multiple queues** if several queues are bound with the same key.
- Use case: point-to-point routing, work queues, selective delivery.

**Example (this repository):**

```
Exchange:  payment-exchange (direct)
Routing key on publish: payment-rk
Binding:   payment-queue → payment-exchange, binding key = payment-rk
```

```java
// Producer
amqpTemplate.convertAndSend("payment-exchange", "payment-rk", message);

// Consumer
@RabbitListener(queues = "payment-queue")
```

If you publish with routing key `payment-rk` but the queue is bound with `payment-other`, the message is **not** delivered — it is dropped (unless alternate exchange is configured).

**Multiple queues, same message:** bind two queues to the same direct exchange with the same binding key `payment-rk`. Both queues receive a copy.

#### Topic Exchange (pattern match)

- Binding key uses wildcards:
  - `*` matches exactly one word (dot-separated segment)
  - `#` matches zero or more words
- Routing key words are separated by `.` (e.g. `payment.created.brazil`).

**Examples:**

| Binding key | Routing key | Match? |
|-------------|-------------|--------|
| `payment.created` | `payment.created` | Yes |
| `payment.*` | `payment.created` | Yes |
| `payment.*` | `payment.created.brazil` | No |
| `payment.#` | `payment.created.brazil` | Yes |
| `*.failed` | `payment.failed` | Yes |
| `#` | anything | Yes |

Use case: event-driven architectures, domain events, multi-tenant routing.

#### Fanout Exchange (broadcast)

- Ignores routing key and binding key.
- Every queue bound to the exchange receives every message.
- Use case: notifications, cache invalidation, audit fan-out.

```
Exchange: notification-exchange (fanout)
Bindings: email-queue, sms-queue, push-queue (no key needed)
→ One publish delivers to all three queues
```

#### Headers Exchange (attribute match)

- Ignores routing key; matches on message headers (`x-match: all` or `any`).
- Less common; useful when routing logic is too complex for topic patterns.

### How Matching Works (Mental Model)

1. Producer publishes to exchange `E` with routing key `RK`.
2. Exchange `E` loads all bindings for that exchange.
3. For each binding, the exchange applies its type-specific match rule.
4. For every match, a copy of the message is routed to the bound queue.
5. If no binding matches, the message is silently dropped (default behavior).

### Common Binding and Routing Mistakes

| Mistake | Symptom | Fix |
|---------|---------|-----|
| Queue exists but no binding | Messages published, queue stays empty | Create binding exchange → queue |
| Wrong routing key on publish | Same as above | Align producer routing key with binding key |
| Typo in binding key (`payment_rk` vs `payment-rk`) | No delivery | Inspect bindings with `rabbitmqctl list_bindings` |
| Expecting fanout behavior on direct exchange | Only one queue receives messages | Use fanout or bind multiple queues with same key |
| Expecting load balancing across consumers on different queues | Each queue gets all messages | Use one queue with multiple consumers (competing consumers) |
| Publishing to default exchange with wrong routing key | Message goes to wrong or non-existent queue | Default exchange routes by queue name; prefer named exchanges in production |
| Binding key pattern too broad (`#`) | Unexpected queues receive sensitive events | Narrow patterns per domain (`payment.*`, `order.#`) |

### Creating Bindings

**Management UI:** Exchanges → select exchange → Add binding → choose queue and binding key.

**rabbitmqadmin:**

```bash
rabbitmqadmin declare binding source=payment-exchange destination=payment-queue routing_key=payment-rk
```

**rabbitmqctl (inspect only):**

```bash
rabbitmqctl list_bindings
rabbitmqctl list_bindings source exchange_name
```

**Spring AMQP:**

```java
@Bean
Binding paymentBinding(Queue paymentQueue, DirectExchange paymentExchange) {
    return BindingBuilder.bind(paymentQueue)
        .to(paymentExchange)
        .with("payment-rk");
}
```

**Topic binding example:**

```java
@Bean
Binding paymentCreatedBinding(Queue paymentCreatedQueue, TopicExchange eventsExchange) {
    return BindingBuilder.bind(paymentCreatedQueue)
        .to(eventsExchange)
        .with("payment.created");
}
```

### Inspecting Bindings in Troubleshooting

When messages are missing, always verify the binding chain:

```bash
# List all bindings (source, destination, routing key)
rabbitmqctl list_bindings

# Filter by exchange
rabbitmqctl list_bindings source payment-exchange

# Management API
curl -u guest:guest http://localhost:15672/api/bindings
```

**Checklist:**

1. Does the exchange exist and have the expected type?
2. Is the queue bound to that exchange?
3. Does the binding key match the routing key used on publish (or pattern for topic)?
4. Is the producer publishing to the correct vhost?
5. Does the user have `write` on the exchange and `read` on the queue?

### Design Guidelines

- **Name routing keys consistently** — use dot notation for topics (`domain.action`, `payment.created`, `order.shipped`).
- **One binding key per intent** — avoid reusing the same key for unrelated flows unless you want duplicate delivery.
- **Document your topology** — exchange type, queues, bindings, and routing keys should be in README or infra-as-code.
- **Prefer explicit config** — declare exchanges, queues, and bindings in code (`@Configuration`) or Terraform/Helm rather than manual UI setup in production.
- **Use alternate exchange** — for unroutable messages, configure an alternate exchange to catch publishes that match no binding (avoids silent loss).

### Hands-on Exercises

1. Publish to `payment-exchange` with routing key `payment-rk` and confirm delivery to `payment-queue`.
2. Change the routing key to `wrong-key` and observe the queue stays empty; inspect bindings.
3. Add a second queue bound with the same key and confirm both receive the message.
4. Switch to topic exchange: bind `payment.*` and test `payment.created` vs `payment.created.brazil`.
5. Remove a binding while the app is running and observe consumer starvation.

### Exit Criteria

- You can explain the difference between routing key and binding key.
- You can predict which queues receive a message given exchange type, bindings, and routing key.
- You can diagnose "messages not arriving" by inspecting bindings in under 5 minutes.
- You can choose direct vs topic vs fanout for a given business scenario.

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
- **Bindings and routing keys (intro):**
  - **Routing key**: label on the message set by the producer at publish time
  - **Binding**: rule linking an exchange to a queue (with a binding key)
  - Producer sets routing key; admin/config creates bindings
  - Direct exchange: routing key must exactly match binding key
  - Unroutable messages are dropped unless alternate exchange is configured
  - See [section 2.2](#22-bindings-and-routing-keys-deep-dive) for full conceptual explanation

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
- Create binding manually: `payment-queue` → `payment-exchange` with key `payment-rk`
- Publish with wrong routing key and confirm message does not arrive; fix binding/key mismatch
- Run `rabbitmqctl list_bindings` and map output to your topology

### Exit Criteria

- You can explain message flow from producer to consumer
- You can create queue/exchange/binding manually in UI
- You can send and receive at least one message end-to-end
- You can explain why a message might be published but never consumed (missing or mismatched binding)

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
- **Bindings and routing keys (applied):**
  - Binding key vs routing key in practice
  - Multiple queues bound with same key (duplicate delivery)
  - One queue, multiple consumers (competing consumers — not a binding concern)
  - Topic patterns: `payment.*`, `payment.#`, `*.failed`
  - Silent message loss when no binding matches
  - Alternate exchange for unroutable messages
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
- Binding lab:
  - Bind two queues to same direct exchange with key `payment-rk`; confirm both receive message
  - Bind one queue with `payment.*` on topic exchange; test matching and non-matching keys
  - Remove binding and observe queue starvation; restore and verify recovery

### Exit Criteria

- You can choose the right exchange type by use case
- You can reason about ordering and parallel consumers
- You can define a stable message schema for integration
- You can design binding topology so the right queues receive the right messages
- You can debug routing issues using `list_bindings` and Management UI

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
   Run `rabbitmqctl list_bindings source <exchange>` and confirm queue is bound with correct key.

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
  - Run `rabbitmqctl list_bindings` — confirm queue is bound to exchange with correct binding key
  - Compare producer routing key vs binding key (exact for direct, pattern for topic)
  - Check exchange type: fanout ignores keys; direct requires exact match
  - Confirm producer publishes to correct vhost
  - Check permissions (`configure`, `write`, `read`)
  - If message is dropped (no matching binding), consider alternate exchange to capture unroutable publishes

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
rabbitmqctl list_bindings source payment-exchange
rabbitmqctl list_bindings destination payment-queue
```

**Reading `list_bindings` output:**

```
source_name    source_kind    destination_name    routing_key
payment-exchange  exchange    payment-queue       payment-rk
```

- `source_name` = exchange messages are published to
- `routing_key` = binding key used for matching
- `destination_name` = queue that receives matched messages

**Declare binding via rabbitmqadmin:**

```bash
rabbitmqadmin declare binding source=payment-exchange destination=payment-queue routing_key=payment-rk
rabbitmqadmin declare binding source=events-exchange destination=payment-created-queue routing_key=payment.created
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
