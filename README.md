#LibGuildInfo
**Author** - Wobin  
**Date** - 25/05/2014  
**Game** - *Elder Scrolls Online*  

This library will retrieve and store guild member information for easy access via account name or character name

##Setup

1. Place the library in your addon folder
2. Reference `LibStub` in your manifest
3. Reference `LibGuildInfo` in your manifest
4. Reference `LibGuildInfo` in your code:   

            local LibGuildInfo = LibStub("LibGuildInfo-1.0")

##API
The following API is defined:

###GetGuildMemberByMemberName

	LibGuildInfo:GetGuildMemberByMemberName(name)

- *name* - being either the account name with the @ symbol or the character name

**Returns**
- *guildInfo* - an object that contains all guild info used in the guild panel

###GetClassNumByMemberName

	LibGuildInfo:GetClassNumByMemberName(name)

- *name* - as above

**Returns**
- *classNum* - a number representing the class 
	- [1] = "Dragon Knight"
	- [2] = "Sorcerer"
	- [3] = "Nightblade"  
	- [6] = "Templar"

###GetClassNameByMemberName

	LibGuildInfo:GetClassNameByMemberName(name)

- *name* - as above

**Returns***
- *className* - The english representation of the class

###GetLevelByMemberName

	GetLevelByMemberName(name)

- *name* - as above

**Returns***
- *level* - Numerical representation of the player character's level. Veteren ranks represented by 'Vx'

###GetAllianceNumByMemberName

    GetAllianceNumByMemberName(name)   

- *name* as above

**Returns**
- *allianceNum* - Numerical representation of the alliance the currently logged in player is a member of
    - [1] = "Aldmeri Dominion"
    - [2] = "Ebonhart Pact"
    - [3] = "Daggerfall Convenant"

###GetAllianceNameByMemberName

    GetAllianceNameByMemberName(name)

- *name* as above

**Returns**
- *allianceName* - The english representation of the Alliance

###GetGuildRankIndexByMemberName

    GetGuildRankIndexByMemberName(name)

- *name* as above

**Returns**
- *rankIndex* - Numerical representation of the account's guild rank (1 is Guild Leader)

###GetGuildRankByMemberName

    GetGuildRankByMemberName(name)

- *name* as above

**Returns**
- *rank* - A more textual representation 'GL' for Guild leader and 'Rx' for subsequent membership
