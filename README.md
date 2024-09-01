# rager

[Simple](https://www.infoq.com/presentations/Simple-Made-Easy/) tools for building LLM applications.

## Goals

Use the minimum level of abstraction

Be useful from low level utilities to high level workflows

Use OTP patterns for robustness

Bring your own HTTP client starting with Req

Different capabilities with abstractions across providers

Each concrete implementation is reponsible for running itself and exposes specific advanced features, therefore if you need something specific that is not in the top level abstraction at the cost of locking yourself in then you are free to use it directly

Integrations should use HTTP interface when possible

Now these are the low level building blocks on which you can build complicated workflows if you want

Build a DAG of agent actions where each node is a process that spawns and is linked to its downstream nodes

Therefore for any errors that node and all downstream nodes are restarted automatically

Finally build a visual editor to create these flows that is saved as code
