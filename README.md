# ACME Corp Audit Logging System

## Introduction
The ACME Corp Audit Logging System is designed to capture and audit user activities for a bug tracking product. The system consumes events from an event bus, processes them, and stores the activities for query and audit purposes. This system supports high throughput with robust filtering capabilities to retrieve relevant audit information quickly and efficiently.

## Deliverables
- **Time Taken**: 6 - 8 hours

## Table of Contents
- [ACME Corp Audit Logging System](#acme-corp-audit-logging-system)
  - [Introduction](#introduction)
  - [Deliverables](#deliverables)
  - [Table of Contents](#table-of-contents)
  - [Installation](#installation)
  - [Technical Stack](#technical-stack)
  - [Architecture](#architecture)
    - [Architectural Diagrams](#architectural-diagrams)
    - [Key Design Decisions](#key-design-decisions)
    - [Why These Choices?](#why-these-choices)
  - [API Documentation](#api-documentation)
    - [Base URL](#base-url)
    - [GET /audit\_events](#get-audit_events)
  - [Notes](#notes)
  - [Docker Setup](#docker-setup)
  - [CLI Interface](#cli-interface)
    - [Available Commands](#available-commands)
      - [1. `authtrail consume`](#1-authtrail-consume)
      - [2. `authtrail emit-sample [COUNT]`](#2-authtrail-emit-sample-count)
      - [3. `authtrail poke`](#3-authtrail-poke)
      - [4. `authtrail serve`](#4-authtrail-serve)
      - [5. `authtrail specs`](#5-authtrail-specs)
    - [General CLI Usage](#general-cli-usage)
  - [Improvements](#improvements)
    - [How to scale further?](#how-to-scale-further)
  - [Testing and Quality Assurance](#testing-and-quality-assurance)
    - [Integration Testing](#integration-testing)
    - [Load Testing](#load-testing)
  - [Production Deployment and Monitoring](#production-deployment-and-monitoring)
    - [Deployment:](#deployment)
    - [Monitoring and Logging:](#monitoring-and-logging)

## Installation
Follow these steps to set up the project locally:
1. **Clone the repository:**
```bash
git clone https://github.com/yourrepository/audit-logging-system.git
```
2. **Navigate to the project directory:**
```bash
cd audit-logging-system
```
3. **Install dependencies:**
```bash
bundle install
```
4. **Environment Setup:**
 Ensure you have `docker` and `docker-compose` installed.

## Technical Stack
- **Language:** Ruby
- **Framework:** Sinatra
- **ORM:** Mongoid for MongoDB
- **Testing:** RSpec
- **Event Handling:** Karafka for Kafka integration
- **Logging:** Console, and Logfile at `log/development.log`
- **Monitoring:** `kafka-ui` and `karafka-web` for monitoring

## Architecture
The system is built on a microservice architecture leveraging Sinatra to expose APIs and Karafka to handle event consumption from Kafka. The application processes and transforms these events before storing them in MongoDB.

### Architectural Diagrams
![System Architecture Diagram](./doc/Untitled%20Diagram.png) 

### Key Design Decisions
- **Scalability**:
  - The use of Kafka allows the system to scale horizontally by adding more consumers as the load increases.
  - Messages are published on partitions based on their `user_id` so events of a particular user are always consumed in order.
  - The consumer is a separate runnable service, allowing multiple instances to be deployed based on the load.
- **Maintainability**:
  - Each component has a clear boundary and responsibility, simplifying updates and maintenance.
- **Performance**:
  - MongoDB facilitates fast retrieval of logged data, supporting complex queries required by the system.
  - Additional partitions can be added to the database if needed.
  - Indices are added for commonly queried attributes.
- **Availability**:
  - Containerizing allows multiple instances of the application to be deployed easily.
  - Karafka has a retry mechanism in case of errors, with dead messages being published to a dead letter queue.

### Why These Choices?
- **Sinatra over other heavier frameworks**: Chosen for its simplicity and lower overhead for serving simple API responses.
- **MongoDB over traditional SQL databases**: Preferred for its flexibility with unstructured data and scalability.
- **Kafka**: Chosen for its robustness in handling stream data and enabling easy scale-out options as data volume or throughput requirements grow.

## API Documentation
The Audit Logging System provides a set of APIs to retrieve and filter audit events stored in the database. Below is a comprehensive guide to utilizing these APIs effectively.

### Base URL
All API endpoints are relative to the following base URL:
```
http://localhost:4000
```

### GET /audit_events
Retrieve paginated audit events with various filtering options.

**Parameters:**
- `page` (integer, optional): The page number you wish to retrieve. Defaults to 1 if not specified.
- `per_page` (integer, optional): The number of events to display per page. Defaults to 10 if not specified.
- `timestamp_from` (integer, optional): The start timestamp for filtering events (in epoch time seconds).
- `timestamp_to` (integer, optional): The end timestamp for filtering events (in epoch time seconds). Requires `timestamp_from` to be specified.
- `user_id` (integer, optional): Filter events by a specific user ID.
- `company_id` (integer, optional): Filter events by a specific company ID.
- `event_type` (string, optional): Filter events by event type.
- `event_resource_type` (string, optional): Filter events by the resource type involved in the event.

**Response:**
A JSON object containing:
- `data`: An array of `AuditEvent` objects representing the paginated results.
- `meta`: An object containing pagination details such as:
  - `current_page`: Current page number.
  - `total_pages`: Total number of available pages.
  - `per_page`: Number of events per page.
  - `total_count`: Total number of events matching the filter criteria.

**Example Requests:**
```http
GET /audit_events
GET /audit_events?page=2&per_page=20
GET /audit_events?user_id=123
GET /audit_events?event_type=login&timestamp_from=1652502000&timestamp_to=1652588400
```

**Error Codes:**
- `400 Bad Request`: Returned if any invalid parameters are provided in the request.

## Notes
- Timestamps should be provided in epoch time format (seconds since the Unix epoch).
- Multiple filter parameters can be combined in a single request to refine search results further.

## Docker Setup
Utilize Docker Compose to orchestrate the environment containing MongoDB, Kafka, and the Sinatra application.
1. **To start the services:**
```bash
docker-compose up
```
2. **To stop the services:**
```bash
docker-compose down
```
Full details and configurations are provided in the [Docker section](#docker-setup) of this README.

## CLI Interface
The `authtrail` command line interface offers several commands to manage and interact with the Audit Logging System. Below are the available commands, their purposes, and examples of how to use them:

### Available Commands
#### 1. `authtrail consume`
- **Description:** Initiates the consumption of events from the configured Kafka topic.
- **Usage:**
```bash
docker-compose run cli consume
```
#### 2. `authtrail emit-sample [COUNT]`
- **Description:** Emits a specified number of sample audit events into the Kafka queue. This is useful for testing and development purposes.
- **Parameters:**
  - `COUNT` (optional): Number of sample events to emit. Defaults to 1 if not specified.
- **Usage:**
```bash
docker-compose run cli emit-sample 10 # Emits 10 sample events
```
#### 3. `authtrail poke`
- **Description:** Performs a quick health check of the system. This is used to verify that all components of the system are operational and can connect to necessary services like databases and message brokers.
- **Usage:**
```bash
docker-compose run cli poke
```
#### 4. `authtrail serve`
- **Description:** Starts the development server, making the web application available on the designated port.
- **Usage:**
```bash
docker-compose run cli serve
```
#### 5. `authtrail specs`
- **Description:** Runs the test suite. This is crucial for ensuring the ongoing reliability of the system through unit and integration tests.
- **Usage:**
```bash
docker-compose run cli specs
```

### General CLI Usage
To execute any of these commands, use the `docker-compose run cli <command>` pattern from the root directory of your project, where the `docker-compose.yml` file is located. Ensure Docker services are running appropriately if required for the command (e.g., `authtrail consume` needs Kafka service running).

## Improvements
### How to scale further?
1. **Add More Partitions to Kafka**: By increasing the number of partitions in Kafka, you allow more consumers to consume messages in parallel. This helps distribute the workload more effectively across the consumer group, leading to improved throughput and reduced latency for data processing.
2. **Schema validation**: We can make use of kafka schema registry to make sure the schema we are getting is valid and processable and to evolve and make changes to the schema as needed. 
3. **Scale the Number of Consumers**: Increasing the number of consumer instances helps in parallel processing of incoming messages. This is particularly effective when you have already increased the number of partitions in Kafka; additional consumers can be added to take advantage of these partitions, enabling faster data processing.
4. **Scale the Database Instances**: As the volume of data grows, scaling out MongoDB can help handle the increased load. MongoDB can be scaled out using sharding, where data is distributed across multiple machines. Additionally, adding more replica sets can increase read throughput and enhance data availability.
5. **Implement Reader-Writer Splits**: For databases, implementing a reader-writer split can significantly enhance performance. This involves separating the read and write operations onto different servers or clusters. Write operations can be directed to the primary node, while read operations can be handled by one or more secondary nodes, balancing the load and improving response times for read queries.
6. **Use MongoDB Kafka Connector**: Replacing Karafka with the MongoDB Kafka Connector could streamline the process from consuming messages in Kafka directly to storing them in MongoDB. This sink connector enables you to directly store processed messages into MongoDB without an intermediary service, reducing complexity and potentially increasing efficiency.
7. **Utilize Caching Mechanisms**: Implement caching for frequently accessed data. This can reduce the load on the database and speed up response times. Technologies like Redis or Memcached can be used for in-memory caching of result sets or intermediate data.
8. **Asynchronous Processing**: Introduce more asynchronous processing in handling data. This approach can help in absorbing peaks in traffic and decouples the components of systems, allowing them more independently manageable growth.
9. **Microservices Architecture**: If the application demands grow, consider breaking down the web application into microservices. This allows each service to be scaled independently based on its specific load and resource requirements.
10. **Monitor and Automate Scaling**: Use auto-scaling capabilities and monitor system performance metrics actively. Tools like Kubernetes can manage container deployments and scale systems automatically based on the load.

## Testing and Quality Assurance

### Integration Testing
**Tools**:
- **RSpec with additional support libraries** (e.g., `database_cleaner`, `factory_bot`).

**Approach**:
- Test the interaction between Sinatra routes and MongoDB to ensure data flows correctly through the system.
- End-to-end tests that simulate a full data flow from event consumption to query.
- Ensure that components like Kafka consumers correctly forward processed data to the database.
  
**Example Scenarios**:
- Lifecycle of an event from being produced in Kafka to being stored in MongoDB.
- API endpoints to fetch audit events based on filters.

### Load Testing
**Definition**: Load testing ensures the system can handle high volume operations and performs well under stress conditions.

**Tools**:
- **Apache JMeter**: For simulating high loads.
- **Locust**: An alternative tool that can be used for performance testing.

**Approach**:
- Simulate 1000msg/second event input to Kafka.
- Ensure event consumption, transformation, and storage can keep up with the load.
- Measure response times for API endpoints under load.
  
**Example Scenarios**:
- Continuous stream of 1000 messages per second for an extended period.
- Simulating peak loads and observing system behavior, including error handling and recovery.



## Production Deployment and Monitoring
### Deployment:
1. **Containerization** : Use Docker to containerize the application, ensuring consistency across different environments.
2. **Orchestration**    : Deploy using Kubernetes or Docker Swarm for orchestration and managing multiple instances of the system.
3. **CI/CD Pipeline**   : Implement a continuous delivery pipeline using tools like GitHub Actions.

### Monitoring and Logging:
1. **Centralized Logging**  : Use tools like ELK Stack (Elasticsearch, Logstash, Kibana) or Graylog for centralized logging and monitoring.
2. **Metrics Collection**   : Implement monitoring solutions like Prometheus and Grafana to collect and visualize system metrics. 
3. **Health Checks**        : Implement health check endpoints and use monitoring tools to regularly check these endpoints for system health.
4. **Alerting**             : Configure alerting based on metrics and logs using tools like PagerDuty, OpsGenie, or simple email alerts.
