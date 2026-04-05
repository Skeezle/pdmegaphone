# skeezle_pdmegaphone

Police vehicle megaphone for **QBX/Qbox** using **pma-voice**, **Native Audio**, and **submix** support.

This resource lets police drive approved vehicles and use a **hold-to-talk megaphone** by holding **Left Shift**. While active, voice range is boosted, nearby players hear a megaphone-style filter, and optional broadcast text can be sent with `/m`.

Based on the included manifest, config, client, and server files.

## Features

- Hold **Left Shift** to activate the megaphone
- Restricted to allowed **jobs**
- Restricted to allowed **police vehicles**
- Supports **addon vehicles by model hash**
- Boosts voice distance while active
- Applies a **megaphone/radio filter** to listeners using submix
- Plays optional **squelch/click** sounds
- Includes optional `/m` broadcast text chat for players in range
- Includes `/mpdebug` command for testing

## Requirements

- **QBX / Qbox**
- **qbx_core**
- **pma-voice**
- FiveM server with **Native Audio** enabled

## Installation

1. Place the resource folder in your server resources.
2. Make sure the folder is named:

```txt
skeezle_pdmegaphone
```

3. Add this to your `server.cfg`:

```cfg
ensure skeezle_pdmegaphone
```

4. Make sure **pma-voice** is started before this resource.
5. Add these convars to `server.cfg` **before** pma-voice starts:

```cfg
setr voice_useNativeAudio true
setr voice_enableSubmix 1
```

## Resource Info

From `fxmanifest.lua`:

- **Name:** `skeezle_pdmegaphone`
- **Author:** `Skeezle`
- **Version:** `1.2.1`
- **Description:** Police vehicle megaphone for QBX/Qbox using pma-voice native audio and submix

## How It Works

The script checks all of the following before activation: 

- You must be in a vehicle
- You must be the **driver**
- Your **job** must be allowed
- The vehicle must be on the allowlist

When active, the script:

- boosts voice proximity
- keeps nearby listeners updated
- applies the megaphone audio filter to listeners
- plays squelch sounds when transmitting
- disables sprint while the megaphone is active if enabled in config

## Default Controls

- **Hold Left Shift** = activate megaphone
- **`/m your message`** = send megaphone text broadcast while holding Shift
- **`/mpdebug`** = test/debug command

Control handling and commands are implemented in the client file.

## Commands

### `/m`

Sends a text broadcast to players within megaphone range.

Rules:

- You must be actively holding Shift first
- You must be driving an allowed vehicle
- Empty messages are ignored
- Broadcasts are range-limited

### `/mpdebug`

Prints debug info to F8 and tests parts of the megaphone setup. 

## Configuration

All main settings are in `config.lua`. 

### Allowed Jobs

```lua
Config.AllowedJobs = {
  police = true,
  sheriff = true,
  state = true,
}
```

Only players with these jobs can use the megaphone by default. 

### Allowed Vehicles

The script supports two allowlist methods:

#### 1. Display name allowlist
Best for most vanilla police vehicles.

```lua
Config.AllowedVehicles = {
  police = true,
  police2 = true,
  police3 = true,
  police4 = true,
  sheriff = true,
  sheriff2 = true,
  fbi = true,
  fbi2 = true,
}
```

#### 2. Model hash allowlist
Best for addon police vehicles.

```lua
Config.AllowedVehicleHashes = {
  [joaat('yourspawnname')] = true,
}
```

Vehicle config is defined here. 

### Keybind

```lua
Config.Keybind = 'LSHIFT'
```

The script uses direct control detection for Left Shift. 

### Range and Timing

```lua
Config.MegaphoneRange = 90.0
Config.HearingRange3D = 90.0
Config.ToggleCooldownMs = 1500
```

- `MegaphoneRange` = who receives effects and broadcast events
- `HearingRange3D` = voice distance while active
- `ToggleCooldownMs` = delay before reactivation

Defined in config here.

### pma-voice Integration

```lua
Config.UsePmaVoiceProximityBoost = true
Config.PreferStateBagProximity = true
```

The script first attempts to use pma-voice proximity override, then falls back to state bag proximity if needed. 

### Chat Broadcast

```lua
Config.ShowChat = true
Config.ChatFormat = '^3[MEGAPHONE]^7 %s'
```

Controls whether `/m` messages appear in chat and how they are formatted.

### Squelch Sound

```lua
Config.EnableSquelch = true
Config.SquelchOnToggle = true
Config.SquelchOnTransmitStart = false
```

The script also includes a fallback frontend sound if the primary sound does not play reliably. 

### Submix / Megaphone Filter

```lua
Config.EnableMegaphoneSubmix = true
```

Submix settings:

```lua
Config.Submix = {
  name = 'skeezle_megaphone',
  freq_low = 300.0,
  freq_hi  = 5500.0,
  rm_mix = 0.08,
  rm_mod_freq = 0.0,
  fudge = 0.0,
  holdMs = 1200,
}
```

These settings control the megaphone audio effect applied to listeners.

### Misc

```lua
Config.Debug = false
Config.DisableSprintWhileActive = true
```

- `Debug` prints extra information to F8
- `DisableSprintWhileActive` prevents sprint while holding the megaphone

Defined here.

## Server Events

The server handles these main network events: 

- `skeezle_pdmegaphone:server:requestBroadcast`
- `skeezle_pdmegaphone:server:talkStart`
- `skeezle_pdmegaphone:server:talkStop`
- `skeezle_pdmegaphone:server:squelchTx`

These are used to:

- send text broadcasts
- notify nearby listeners when megaphone speech starts/stops
- trigger transmit squelch for nearby listeners

## Notes

- This script is **driver-only**
- This script is intended for **police-style vehicles only** unless you add more vehicles/jobs
- Addon vehicles should usually be added to `Config.AllowedVehicleHashes`
- Native audio must be enabled for the megaphone submix effect to work properly

## Troubleshooting

### Megaphone does not work

Check the following:

- your job is included in `Config.AllowedJobs`
- your vehicle is included in `Config.AllowedVehicles` or `Config.AllowedVehicleHashes`
- you are the **driver**
- `pma-voice` is running
- `voice_useNativeAudio` is set to `true`
- `voice_enableSubmix` is set to `1`

Relevant checks exist in the client and server files. 

### `/m` does not send

- You must be actively holding **Shift**
- You must be in an allowed vehicle
- `Config.ShowChat` should be enabled if you want chat output shown

### No audio filter is heard

- confirm Native Audio is enabled in `server.cfg`
- confirm submix is enabled
- confirm `Config.EnableMegaphoneSubmix = true`

### Need more debug info

Use:

```txt
/mpdebug
```

This prints pma-voice state and voice convars to F8.

## License

This project is licensed under the MIT License. You are free to use, modify, and distribute this script, including for commercial use, as long as the original license notice is included.

## Credits

**Skeezle Scripts**
