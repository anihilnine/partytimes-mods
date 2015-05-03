local original_UpdateScoreData = UpdateScoreData 

function UpdateScoreData(newData) 
  original_UpdateScoreData(newData) 
  
  import('/mods/hot/lua/allunits.lua').UpdateScoreData(newData) 
end