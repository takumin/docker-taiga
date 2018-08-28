# -*- coding: utf-8 -*-

from kombu import Queue

broker_url = 'amqp://guest:guest@localhost:5672//'
result_backend = 'redis://localhost:6379/0'

accept_content = ['pickle',] # Values are 'pickle', 'json', 'msgpack' and 'yaml'
task_serializer = "pickle"
result_serializer = "pickle"

timezone = 'Europe/Madrid'

task_default_queue = 'tasks'
task_queues = (
    Queue('tasks', routing_key='task.#'),
    Queue('transient', routing_key='transient.#', delivery_mode=1)
)
task_default_exchange = 'tasks'
task_default_exchange_type = 'topic'
task_default_routing_key = 'task.default'
