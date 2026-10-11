# Framework overlays

Keep these **opt-in**. A dev should be able to run bare opencode, opencode+BMAD,
or opencode+skills without maintaining three different images.

| Overlay | Install | Scope |
|---|---|---|
| BMAD | per-project, via its own installer | writes agents/workflows into the repo |
| Superpowers-style skills | per-image or per-user | dropped into opencode's skills dir |

Both inject large system prompts and long plan files. On a local model that is
the main cause of degradation: the context fills, tool-call fidelity drops, the
loop stalls. Measure tokens per phase before blaming the model.

Note that OpenShell itself ships agent skills (`openshell-cli`,
`generate-sandbox-policy`, `debug-inference`) discoverable from `.agents/skills/`
— useful for having the agent help maintain its own policy.
