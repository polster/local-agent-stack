# Notes for a security review

The argument for this stack, stated plainly.

## What it improves

1. **No model API key anywhere.** Inference is on-device, so there is no
   provider credential for a prompt-injected agent to exfiltrate. This is the
   single biggest win and it comes from MLX, not from OpenShell.
2. **No prompt or source leaves the machine.** Relevant for customer data and
   for code under NDA.
3. **Enforcement is in the kernel, not in a wrapper.** OpenShell applies
   Landlock (filesystem) and seccomp (process) inside the sandbox supervisor and
   forces egress through a local policy proxy. An agent that decides to ignore
   its instructions still cannot open a socket the policy forbids.
4. **The policy is a reviewable artifact.** `openshell/policies/*.yaml` is
   version-controlled, diffable, and reviewable like IaC. That is the thing to
   put in front of a reviewer, not a description of the tool.

## What it does not improve

- **Supply chain.** The agent still installs npm/PyPI packages if the profile
  allows it. Point the registry rules at internal mirrors.
- **The repo itself.** `dev-workspace` lets the agent write source. Review
  agent-authored commits like any other contribution; sandboxing is not review.
- **Alpha-grade software.** OpenShell is early and targeted at
  single-developer, single-environment use. Treat team rollout as a pilot with a
  named owner, not a mandated toolchain.
- **Model behaviour.** A sandbox constrains blast radius, not judgement.

## Open questions to close before team rollout

- Which policy fields does our pinned OpenShell version actually enforce, and
  what happens on a malformed policy — fail closed, or fail open?
- Which OpenShell policy fields are enforced in our pinned version, and which
  authored fields are ignored or rejected?
- Where do weights come from — internal mirror with checksums, or Hugging Face?
- Who owns version bumps, and how do we roll back a bad policy change?
