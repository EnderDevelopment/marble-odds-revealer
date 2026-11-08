# Roblox Server Script for Marbles Even/Odd Reveals

Marble Odds Revealer is a Roblox server script that monitors tagged NPCs, determines whether each selected marble count is even or odd, stores the result on the NPC, displays the outcome above the NPC, and broadcasts the server-determined result to all clients.

## Install

1. Insert `MarblesEvenOdd.server.lua` into `ServerScriptService` as a normal `Script`.
2. In Roblox Studio, use the Tag Editor to add the `MarblesNPC` tag to each NPC `Model` or `BasePart` that should be monitored.
3. Make sure each NPC has a `Head`, `PrimaryPart`, or another descendant `BasePart` so the overhead result display has an attachment point.
4. After your existing NPC logic selects a marble count, set the NPC's `MarblesPicked` attribute from a server script:

```lua
npc:SetAttribute("MarblesPicked", pickedMarbleCount)
```

## Use

When the `MarblesPicked` attribute changes, the script:

1. Converts numeric or numeric-string values to a non-negative whole number.
2. Determines whether the count is `Even` or `Odd`.
3. Stores the result in the NPC's `MarblesResult` attribute.
4. Displays `NPC picked <count>: <Even or Odd>` above the NPC for eight seconds.
5. Fires the `MarblesResultRevealed` `RemoteEvent` in `ReplicatedStorage` to every client with `(npc, count, result)`.

A client can listen for the broadcast event if a custom interface is needed:

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local resultEvent = ReplicatedStorage:WaitForChild("MarblesResultRevealed")

resultEvent.OnClientEvent:Connect(function(npc, count, result)
	print(npc.Name, count, result)
end)
```

A separate server script can also call the exposed server function:

```lua
local success, result = _G.RevealMarblesNpcPick(npc, pickedMarbleCount)
```

The script only reveals a count selected by existing server-side NPC logic. It does not choose the NPC's marble count, implement NPC decision-making, or manage the complete marble-round game flow.

---

More Roblox script projects by EnderDevelopment: https://github.com/EnderDevelopment

Project page: https://dash.enderdevelopment.com/community/9de0eb6f-47ce-4cc3-b0c6-af60a6fa4e48?utm_source=github&utm_medium=readme&utm_campaign=auto_publish&utm_content=9de0eb6f-47ce-4cc3-b0c6-af60a6fa4e48
