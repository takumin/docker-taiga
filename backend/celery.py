# -*- coding: utf-8 -*-

from kombu import Queue
import environ

env = environ.Env(
    TZ=(str, 'UTC'),
    RABBITMQ_USER=(str, 'taiga'),
    RABBITMQ_PASS=(str, 'taiga'),
    RABBITMQ_HOST=(str, 'rabbitmq'),
    RABBITMQ_PORT=(int, 5672),
    RABBITMQ_NAME=(str, 'taiga'),
    REDIS_HOST=(str, 'redis'),
    REDIS_PORT=(int, 6379),
)

timezone = env('TZ')

broker_url = 'amqp://{USER}:{PASS}@{HOST}:{PORT}/{NAME}'.format(
    USER=env('RABBITMQ_USER'),
    PASS=env('RABBITMQ_PASS'),
    HOST=env('RABBITMQ_HOST'),
    PORT=env('RABBITMQ_PORT'),
    NAME=env('RABBITMQ_NAME'),
)
result_backend = 'redis://{HOST}:{PORT}/0'.format(
    HOST=env('REDIS_HOST'),
    PORT=env('REDIS_PORT'),
)

# Values are 'pickle', 'json', 'msgpack' and 'yaml'
accept_content = ['pickle']
task_serializer = "pickle"
result_serializer = "pickle"

task_default_queue = 'tasks'
task_queues = (
    Queue('tasks', routing_key='task.#'),
    Queue('transient', routing_key='transient.#', delivery_mode=1)
)
task_default_exchange = 'tasks'
task_default_exchange_type = 'topic'
task_default_routing_key = 'task.default'
