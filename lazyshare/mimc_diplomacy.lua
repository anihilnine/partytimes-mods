--key=mimcID, value=armyID 
local mimcIDs = {}

--key=armyIndex, value=mimcID if is a teammate | value=-1 if isn't a teammate
local alliedIDs = {}

function getLazyShareIDs()
	return mimcIDs
end

function getAlliedIDs()
	return alliedIDs
end

--function to give units to an allied player
function mimc_giveSelectedUnitsToAlly(giveAll, mimcID)

	local focusArmy = GetFocusArmy()
	local mID
	
	--if mimcIDs[mimcID] ~= nil and IsAlly(focusArmy, mimcIDs[mimcID]) then
		if (giveAll) then
		
			-- check if it a valid mimcID
			if (mimcIDs[mimcID] == nil or not IsAlly(focusArmy, mimcIDs[mimcID])) and (mimcIDs[1] ~= nil) then
				-- oh oh, it was the panic button and the id doesn't exists and we have other mates... we should help him out. ;)
				mID = mimcIDs[1]
			else
				mID = mimcIDs[mimcID]
			end

			UISelectionByCategory("ALLUNITS", false, false, false, false)
			
			--first give to preferred mate
			SimCallback( { Func="GiveResourcesToPlayer",
        	                   Args={ From=focusArmy,
                	                  To=mID,
                        	          Mass= 100.0 / 100.0,
                                	  Energy= 100.0 / 100.0,
                                	}
                             	} )
			SimCallback({Func="GiveUnitsToPlayer", Args={ From=focusArmy, To=mID},} , true)
			
	 	 	for index, id in getAllyIDs(mID) do
				
				--Give Ressources to current mate.
				SimCallback( { Func="GiveResourcesToPlayer",
        	                   Args={ From=focusArmy,
                	                  To=id,
                        	          Mass= 100.0 / 100.0,
                                	  Energy= 100.0 / 100.0,
                                	}
                             	} )
                --Give Units to current mate.
				SimCallback({Func="GiveUnitsToPlayer", Args={ From=focusArmy, To=id},} , true)
			end

		else
			if mimcIDs[mimcID] ~= nil and IsAlly(focusArmy, mimcIDs[mimcID]) then
				SimCallback({Func="GiveUnitsToPlayer", Args={ From=GetFocusArmy(), To=mimcIDs[mimcID]},} , true)
			end
		end
	--end
end

function mimc_giveRessToAlly(massValue, energieValue, mimcID)

	local focusArmy = GetFocusArmy()
	
	if mimcIDs[mimcID] ~= nil and IsAlly(focusArmy, mimcIDs[mimcID]) then
		SimCallback( { Func="GiveResourcesToPlayer",
                           Args={ From=GetFocusArmy(),
                                  To=mimcIDs[mimcID],
                                  Mass= massValue / 100.0,
                                  Energy= energieValue / 100.0,
                                }
                             }
                           )
	end
end

--function to get all allied ids
function getAllyIDs(mimcID)

	local focusArmy = GetFocusArmy()
    local armyIndices = {}
    local i = 1
    local j = 0
    for index, playerInfo in GetArmiesTable().armiesTable do

        if IsAlly(focusArmy, index) and index ~= focusArmy and index ~= mimcIDs[mimcID] then
		armyIndices[j] = index
		j = j + 1
        end

        i = i + 1
    end

    return armyIndices
end

--returns a new name for each teamate including his MIMC-ID
--function mimc_getNewNickname(armyIndex, nickname)    
function mimc_getID(armyIndex)    
	
    --local newNickname = nickname
	local newNickname = ' '
    local mimcID = 1
    local focusArmy = GetFocusArmy()
    local armiesInfo = GetArmiesTable().armiesTable

    if not SessionIsReplay() and not armiesInfo[focusArmy].outOfGame then
    
        for index, playerInfo in armiesInfo do
    	    --check if id is from a teammate
            if IsAlly(focusArmy, index) and index ~= focusArmy and mimcID < 4 and not playerInfo.outOfGame then
        	if  index == armyIndex then
        	    --save mimcID and armyIndex
                    mimcIDs[mimcID] = armyIndex
					alliedIDs[armyIndex] = mimcID
        	    --we have our mate, so we can return newNickname
        	    --newNickname = newNickname  .. '(' .. mimcID .. ')'
				newNickname = mimcID
		    break
		else
		    mimcID = mimcID + 1
			alliedIDs[armyIndex] = -1
		end
            end

        end

    end

    return newNickname
end
