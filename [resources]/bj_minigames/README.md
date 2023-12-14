# BJ Minigames

# Events
## `bj_minigames:start`

#### Parameters

| Parameter | Type | Required | Description |
|--|--|--|--|
| mgType | String | True | Minigame type (see list of 'Available Minigames'). |
| mgData | Object | False | Minigame specific data (see list of 'Available Minigames'). |
| mgSuccess | Function | False | Callback function when user completes the minigame. Also has a parameter of 'data' that may contain additional information specific to the minigame. I.e. the Pincode minigame will return the users input. |
| mgFail | Function | False | Callback function when user fails the minigame. |

#### Example
```lua
TriggerEvent('bj_minigames:start', 'Lockpick', { pins = 3, timeout = 18000 }, function(data)
	-- If succeeded minigame callback
end, function()
	-- If failed minigame callback
end)
```

## `bj_minigames:stop`

#### Parameters

| Parameter | Type | Required | Description |
|--|--|--|--|
| mgType | String | True | Minigame type (see list of 'Available Minigames'). |

#### Example
```lua
TriggerEvent('bj_minigames:stop', 'Lockpick')
```

# Available minigames

### Bruteforce
- ConnectHack
- Datacrack
- Fingerprint
- Lockbox (Fallout style lockpicking)
- Lockpick
- Pincode
- Connection
- Safecrack