# bj_ids - Card Config Object

This can be repeated for multiple different "types" of cards defined in the `client.lua` -> `cardImageConfig` variable.

You can then configure these like shown in the `server.lua` to hook them up to items.

```lua
{
    offset = { -- Offset of ped headshot on card
        x = 10,
        y = -75
    },
    scale = { -- Scale of ped headshot on card
        x = 130,
        y = 170
    },
    textColour = { r = 255, g = 255, b = 255 }, -- General text colour 
    fields = {
        {
            type = 'firstname', -- Available fields: source, fullname, lastname, dob, citizenid, gender, nationality, callsign
            offset = { -- Offset of the text
                x = 145,
                y = -50
            },
            justify = 1, -- Text justification (see native docs)
            textScale = 0.32 -- Font size
        }
    },
    useFibBadge = true, -- Use the police show animation instead
    cardOverlayed = true -- Is the card above or below the ped headshot
}
```